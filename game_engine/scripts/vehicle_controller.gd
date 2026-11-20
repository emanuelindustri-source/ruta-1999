extends CharacterBody3D
# VEHICLE CONTROLLER - RUTA 1999
# Fisica de conduccion, caja P-R-N-D-2-L, soporte para giroscopio, acelerometro y camara dual.

@export var max_speed: float = 38.0 # ~137 km/h en m/s
@export var acceleration: float = 8.5 # m/s^2
@export var braking: float = 16.0 # m/s^2
@export var turn_speed: float = 1.8 # rad/s

var current_speed: float = 0.0 # m/s
var steer_input: float = 0.0 # -1.0 a +1.0
var throttle_input: float = 0.0 # 0.0 a 1.0
var brake_input: float = 0.0 # 0.0 a 1.0

# Camaras
@onready var cockpit = $CarCockpit
@onready var cam_first_person = $CarCockpit/CameraFirstPerson
@onready var cam_third_person = $CarCockpit/CameraThirdPerson

var original_cam_rot: Vector3 = Vector3.ZERO
var head_look_rot: Vector2 = Vector2.ZERO # x: pitch, y: yaw

func _ready():
	if cam_first_person:
		original_cam_rot = cam_first_person.rotation
	print("[VehicleController] Araguaney '99 listo para rodar.")

func _physics_process(delta):
	# Si el motor no esta encendido, no hay aceleracion
	if not VehicleState.engine_running:
		current_speed = lerp(current_speed, 0.0, delta * 2.0)
		apply_movement(delta)
		return

	# Control de Volante (Tactil o Inclinacion por Acelerometro)
	var final_steer = steer_input
	if SensorManager.use_accel_steer:
		final_steer = SensorManager.tilt_steer

	# Ajuste de potencia segun marcha P-R-N-D-2-L
	var available_accel = acceleration
	var speed_limit = max_speed

	# Perdida de potencia barometrica en los Andes
	var power_loss_factor = 1.0
	if SensorManager.current_altitude > 1800.0:
		var loss_pct = (SensorManager.current_altitude - 1800.0) / 2000.0 * 35.0
		power_loss_factor = 1.0 - (loss_pct / 100.0)

	match VehicleState.current_gear:
		VehicleState.ShifterMode.P:
			available_accel = 0.0
			current_speed = 0.0
		VehicleState.ShifterMode.N:
			available_accel = 0.0
			current_speed = lerp(current_speed, 0.0, delta * 0.8)
		VehicleState.ShifterMode.R:
			speed_limit = 12.0
			if throttle_input > 0.0:
				current_speed = lerp(current_speed, -speed_limit, delta * (available_accel * 0.6))
		VehicleState.ShifterMode.D:
			# Marcha directa: afectada fuertemente por falta de oxigeno en subida
			available_accel *= power_loss_factor
			if throttle_input > 0.0:
				current_speed = lerp(current_speed, speed_limit, delta * available_accel)
		VehicleState.ShifterMode.TWO:
			# Segunda forzada: mas torque para subir la cuesta
			speed_limit = 22.0
			available_accel *= 1.25 # Mayor fuerza en baja
			if throttle_input > 0.0:
				current_speed = lerp(current_speed, speed_limit, delta * available_accel)
		VehicleState.ShifterMode.L:
			# Primera / Low: maxima compresion y torque
			speed_limit = 14.0
			available_accel *= 1.5
			if throttle_input > 0.0:
				current_speed = lerp(current_speed, speed_limit, delta * available_accel)

	# Freno
	if brake_input > 0.0:
		current_speed = lerp(current_speed, 0.0, delta * braking * brake_input)

	# Desaceleracion pasiva (friccion de rodaje y viento)
	if throttle_input == 0.0 and brake_input == 0.0:
		current_speed = lerp(current_speed, 0.0, delta * 0.9)

	# Giro del carro
	if abs(current_speed) > 0.5:
		var dir_factor = 1.0 if current_speed >= 0.0 else -1.0
		rotate_y(-final_steer * turn_speed * delta * dir_factor)

	apply_movement(delta)
	update_head_look(delta)

func apply_movement(_delta):
	var forward = -transform.basis.z
	velocity = forward * current_speed
	move_and_slide()

# Actualizacion de mirada por Giroscopio en 1ra persona
func update_head_look(delta):
	if cockpit.is_first_person and cam_first_person and SensorManager.use_gyro_look:
		# Acumular rotacion de giroscopio con limites anatomicos del cuello
		head_look_rot.y = clamp(head_look_rot.y - SensorManager.gyro_rotation.y * delta * 2.5, -1.3, 1.3)
		head_look_rot.x = clamp(head_look_rot.x - SensorManager.gyro_rotation.x * delta * 2.5, -0.6, 0.6)
		cam_first_person.rotation.y = original_cam_rot.y + head_look_rot.y
		cam_first_person.rotation.x = original_cam_rot.x + head_look_rot.x

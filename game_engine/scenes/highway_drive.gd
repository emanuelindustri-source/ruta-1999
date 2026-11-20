extends Node3D
# HIGHWAY DRIVE SCENE - RUTA 1999
# Carretera nocturna venezolana con baches, iluminacion de sodio y telemetria HUD.

@onready var vehicle = $Vehicle
@onready var label_speed = $UI/HUD/TopRight/LabelSpeed
@onready var label_gear = $UI/HUD/TopRight/LabelGear
@onready var label_baro = $UI/HUD/TopLeft/LabelBarometer
@onready var label_alt = $UI/HUD/TopLeft/LabelAltitude
@onready var label_alert = $UI/HUD/CenterAlert/LabelAlert
@onready var btn_control_mode = $UI/HUD/ControlsBar/BtnControlMode

func _ready():
	# Iniciar motor para la carretera
	VehicleState.start_engine()
	VehicleState.shift_gear(VehicleState.ShifterMode.D)
	SensorManager.current_altitude = 620.0 # Altitud inicial en Troncal 5
	print("[HighwayDrive] Escena de carretera nocturna iniciada.")

func _process(_delta):
	if vehicle:
		var speed_kmh = int(vehicle.current_speed * 3.6)
		if label_speed:
			label_speed.text = "VELOCIDAD: %d KM/H" % speed_kmh
		if label_gear:
			label_gear.text = "MARCHA: [%s]" % VehicleState.ShifterMode.keys()[VehicleState.current_gear]
	
	if label_baro:
		label_baro.text = "BARÓMETRO: %d hPa" % int(SensorManager.barometric_pressure)
	if label_alt:
		label_alt.text = "ALTITUD: %d msnm" % int(SensorManager.current_altitude)

# Controles Tactiles: Direccion
func _on_btn_steer_left_down():
	if vehicle: vehicle.steer_input = -1.0

func _on_btn_steer_left_up():
	if vehicle and vehicle.steer_input < 0.0: vehicle.steer_input = 0.0

func _on_btn_steer_right_down():
	if vehicle: vehicle.steer_input = 1.0

func _on_btn_steer_right_up():
	if vehicle and vehicle.steer_input > 0.0: vehicle.steer_input = 0.0

# Controles Tactiles: Acelerador y Freno
func _on_btn_throttle_down():
	if vehicle: vehicle.throttle_input = 1.0

func _on_btn_throttle_up():
	if vehicle: vehicle.throttle_input = 0.0

func _on_btn_brake_down():
	if vehicle: vehicle.brake_input = 1.0

func _on_btn_brake_up():
	if vehicle: vehicle.brake_input = 0.0

# Cambio de Marcha
func _on_btn_shift_p_pressed(): VehicleState.shift_gear(VehicleState.ShifterMode.P)
func _on_btn_shift_r_pressed(): VehicleState.shift_gear(VehicleState.ShifterMode.R)
func _on_btn_shift_n_pressed(): VehicleState.shift_gear(VehicleState.ShifterMode.N)
func _on_btn_shift_d_pressed(): VehicleState.shift_gear(VehicleState.ShifterMode.D)
func _on_btn_shift_2_pressed(): VehicleState.shift_gear(VehicleState.ShifterMode.TWO)
func _on_btn_shift_l_pressed(): VehicleState.shift_gear(VehicleState.ShifterMode.L)

# Alternar Modo de Control (Tactil / Acelerometro)
func _on_btn_control_mode_pressed():
	SensorManager.use_accel_steer = not SensorManager.use_accel_steer
	if btn_control_mode:
		btn_control_mode.text = "VOLANTE: INCLINACIÓN" if SensorManager.use_accel_steer else "VOLANTE: BOTONES"
	print("[HighwayDrive] Modo de control: ", "Inclinacion por Acelerometro" if SensorManager.use_accel_steer else "Botones Tactiles")

# Alternar Camara (1ra / 3ra Persona)
func _on_btn_cam_toggle_pressed():
	if vehicle and vehicle.cockpit:
		vehicle.cockpit.toggle_camera()

# Tocar Bocina
func _on_btn_horn_pressed():
	if vehicle and vehicle.cockpit:
		vehicle.cockpit.trigger_horn()

# Pothole Impact Simulation (Bache)
func _on_pothole_area_body_entered(body):
	if body == vehicle:
		SensorManager.trigger_pothole_shock(1.2)
		if label_alert:
			label_alert.text = "[!] ¡TRONERA EN VÍA! SACUDIDA DE SUSPENSIÓN"
			await get_tree().create_timer(1.8).timeout
			label_alert.text = ""

# Subir Altitud al Páramo de Mucuchíes (Mérida)
func simulate_altitude_climb(target_alt: float):
	SensorManager.current_altitude = target_alt
	if target_alt > 2500.0:
		if label_alert:
			label_alert.text = "[!] PÁRAMO DE MÉRIDA (3.450 msnm) - BAJA A [2] PARA NO AHOGAR EL MOTOR"

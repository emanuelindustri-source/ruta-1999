extends Node
# SENSOR MANAGER - RUTA 1999
# Gestiona el Giroscopio, Acelerometro y Barometro (fisico y simulado por altitud andina)

signal barometric_pressure_changed(pressure_hpa, altitude_meters)
signal altitude_power_loss(loss_percentage)
signal severe_weather_warning(warning_text)

# Variables de Sensores
var gyro_rotation: Vector3 = Vector3.ZERO
var accel_raw: Vector3 = Vector3.ZERO
var tilt_steer: float = 0.0 # -1.0 a +1.0 para el volante

# Barometro y Altitud
var current_altitude: float = 480.0 # Metros sobre el nivel del mar
var barometric_pressure: float = 955.0 # hPa (Hectopascales)
var simulated_weather_pressure_drop: float = 0.0

# Calibracion de Sensores
var gyro_sensitivity: float = 1.2
var tilt_sensitivity: float = 0.25
var use_gyro_look: bool = true
var use_accel_steer: bool = false # Si es falso, se usan botones/volante tactil

func _ready():
	print("[SensorManager] Inicializando hardware de sensores para Android...")

func _process(delta):
	# 1. Lectura del Giroscopio (Mirada libre de cabeza dentro del carro)
	var gyro = Input.get_gyroscope()
	if gyro.length() > 0.01:
		gyro_rotation.x = lerp(gyro_rotation.x, gyro.x * gyro_sensitivity, delta * 8.0)
		gyro_rotation.y = lerp(gyro_rotation.y, gyro.y * gyro_sensitivity, delta * 8.0)
		gyro_rotation.z = lerp(gyro_rotation.z, gyro.z * gyro_sensitivity, delta * 8.0)

	# 2. Lectura del Acelerometro (Inclinacion para volante)
	var accel = Input.get_accelerometer()
	accel_raw = accel
	if use_accel_steer and accel.length() > 0.1:
		# En orientacion horizontal (Landscape), el eje X o Y corresponde al giro
		tilt_steer = clamp(-accel.y * tilt_sensitivity, -1.0, 1.0)

	# 3. Calculo Barometrico Realista
	# Presion barometrica segun altitud: P = P0 * exp(-M*g*h / (R*T0))
	var base_pressure = 1013.25 * pow(1.0 - (0.0065 * current_altitude) / 288.15, 5.255)
	barometric_pressure = base_pressure - simulated_weather_pressure_drop
	
	emit_signal("barometric_pressure_changed", barometric_pressure, current_altitude)

	# Perdida de potencia por falta de oxigeno en los Andes (Páramo)
	# A 3.450 msnm (Mucuchies), la presion cae a ~680 hPa y el motor 1.6L pierde hasta 35% de potencia
	if current_altitude > 1800.0:
		var loss = clamp((current_altitude - 1800.0) / 2000.0 * 35.0, 0.0, 38.0)
		emit_signal("altitude_power_loss", loss)

# Funcion para simular baches / troneras con respuesta haptica
func trigger_pothole_shock(severity: float = 1.0):
	# Vibracion fisica del telefono
	var vibe_ms = int(120 * severity)
	Input.vibrate_handheld(vibe_ms)
	print("[SensorManager] Tronera en carretera. Impacto haptico: ", vibe_ms, "ms.")

# Simular caida repentina de presion (anuncio de tormenta o El Silbón)
func trigger_paranormal_pressure_drop(amount_hpa: float = 25.0):
	simulated_weather_pressure_drop = amount_hpa
	emit_signal("severe_weather_warning", "CAÍDA BAROMÉTRICA SÚBITA: Perturbación atmosférica detectada.")
	print("[SensorManager] Advertencia barometrica paranormal activada.")

extends Node
# VEHICLE STATE SINGLETON (AUTOLOAD) - RUTA 1999
# Mantiene el estado continuo del Sedan Araguaney '99 a traves de todas las escenas.

signal motor_started
signal motor_stopped
signal window_changed(window_name, position)
signal door_locks_changed(is_locked)
signal lights_changed(mode)
signal wiper_changed(mode)
signal npc_paranoia_alert(message)

# Estado del Motor y Fluidos
var engine_running: bool = false
var engine_temp: float = 22.0 # Grados Celsius (arranca frio en garaje)
var fuel_level: float = 75.0 # Porcentaje
var oil_level: float = 95.0 # Porcentaje
var radiator_water: float = 92.0 # Porcentaje
var battery_charge: float = 100.0

# Transmision Automatica (0: P, 1: R, 2: N, 3: D, 4: 2, 5: L)
enum ShifterMode { P, R, N, D, TWO, L }
var current_gear: ShifterMode = ShifterMode.P

# 4 Ventanas Electricas (0.0: Cerrada, 1.0: Completamente Abierta)
var window_fl: float = 0.0 # Conductor
var window_fr: float = 0.0 # Copiloto
var window_rl: float = 0.0 # Trasera Izquierda
var window_rr: float = 0.0 # Trasera Derecha

# Seguros e Iluminacion
var central_locked: bool = false
enum DomeLightMode { OFF, DOOR, ON }
var dome_light: DomeLightMode = DomeLightMode.DOOR

enum HeadlightsMode { OFF, PARKING, LOW, HIGH }
var headlights: HeadlightsMode = HeadlightsMode.OFF
var hazard_lights: bool = false

enum WiperMode { OFF, INT, LOW, HIGH }
var wipers: WiperMode = WiperMode.OFF

# Posicion del Asiento del Conductor (-1.0: Adelante, 0.0: Neutro, 1.0: Totalmente Atras)
var driver_seat_pos: float = 0.0

# Guantera e Inventario
var glovebox_open: bool = false
var has_flashlight: bool = true
var flashlight_battery: float = 85.0
var has_map: bool = true
var cash_bolivares: int = 18400
var cassette_loaded: String = "Exitos Pop 1999 - Lado A"

# Presencia de Pasajeros y Psicologia
var passenger_onboard: bool = false
var passenger_name: String = ""
var passenger_paranoia: float = 0.0 # 0 a 100

func _ready():
	print("[VehicleState] Sistema de telemetria del Sedan Araguaney '99 activo.")

# Metodo para arrancar el motor
func start_engine() -> bool:
	if engine_running:
		return true
	if fuel_level <= 0.0 or battery_charge < 15.0:
		print("[VehicleState] Falla de arranque: Sin combustible o bateria agotada.")
		return false
	engine_running = true
	emit_signal("motor_started")
	print("[VehicleState] Motor 1.6L encendido en ralenti.")
	return true

func stop_engine():
	if not engine_running:
		return
	engine_running = false
	emit_signal("motor_stopped")
	print("[VehicleState] Motor 1.6L apagado.")

# Control de ventanas
func set_window_position(win_name: String, pos: float):
	pos = clamp(pos, 0.0, 1.0)
	match win_name:
		"fl": window_fl = pos
		"fr": window_fr = pos
		"rl": window_rl = pos
		"rr": window_rr = pos
	emit_signal("window_changed", win_name, pos)

# Control de seguros con reaccion psicologica de pasajero
func toggle_central_lock() -> bool:
	central_locked = not central_locked
	emit_signal("door_locks_changed", central_locked)
	
	if passenger_onboard and central_locked:
		passenger_paranoia += 25.0
		var msg = "¿Por que le pones seguro al carro, chamo? ¿Que inventas?"
		emit_signal("npc_paranoia_alert", msg)
		print("[VehicleState] Pasajero alterado: ", msg)
	
	return central_locked

# Ajustar asiento
func adjust_seat(direction: float):
	driver_seat_pos = clamp(driver_seat_pos + direction, -1.0, 1.0)
	if passenger_onboard and driver_seat_pos > 0.6:
		passenger_paranoia += 10.0
		emit_signal("npc_paranoia_alert", "Mano, echaste el asiento muy atras, me estas apretando las piernas...")

# Cambiar marcha
func shift_gear(new_gear: ShifterMode):
	current_gear = new_gear
	print("[VehicleState] Marcha seleccionada: ", ShifterMode.keys()[current_gear])

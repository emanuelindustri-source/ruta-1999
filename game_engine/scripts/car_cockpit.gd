extends Node3D
# CAR COCKPIT CONTROLLER - RUTA 1999
# Controla la interactividad del habitaculo beige del Sedan Araguaney '99 y la camara dual.

@onready var cam_first_person = $CameraFirstPerson
@onready var cam_third_person = $CameraThirdPerson

# Reproductores de Audio 3D Posicional
@onready var sfx_starter = $AudioStarter
@onready var sfx_engine = $AudioEngineIdle
@onready var sfx_click = $AudioClick
@onready var sfx_lock = $AudioLock
@onready var sfx_horn = $AudioHorn
@onready var sfx_glovebox = $AudioGlovebox
@onready var sfx_window = $AudioWindow
@onready var sfx_wiper = $AudioWiper

# Partes Animadas
@onready var mesh_steering_wheel = $CockpitMesh/SteeringWheel
@onready var mesh_shifter = $CockpitMesh/Shifter
@onready var mesh_glovebox_door = $CockpitMesh/GloveboxDoor
@onready var mesh_dome_light = $CockpitMesh/DomeLight
@onready var light_interior = $CockpitMesh/DomeLight/InteriorOmniLight
@onready var headlights_spot = $FrontHeadlights

# Camaras: 0 = Primera Persona (Default), 1 = Tercera Persona
var is_first_person: bool = true

func _ready():
	setup_audio_players()
	update_camera_mode()
	print("[CarCockpit] Habitaculo 3D del Araguaney '99 inicializado.")

func setup_audio_players():
	# Cargar recursos de audio sintetizados
	if sfx_starter and FileAccess.file_exists("res://assets/audio/starter_crank.wav"):
		sfx_starter.stream = load("res://assets/audio/starter_crank.wav")
	if sfx_engine and FileAccess.file_exists("res://assets/audio/engine_idle.wav"):
		sfx_engine.stream = load("res://assets/audio/engine_idle.wav")
	if sfx_click and FileAccess.file_exists("res://assets/audio/switch_click.wav"):
		sfx_click.stream = load("res://assets/audio/switch_click.wav")
	if sfx_lock and FileAccess.file_exists("res://assets/audio/door_lock.wav"):
		sfx_lock.stream = load("res://assets/audio/door_lock.wav")
	if sfx_horn and FileAccess.file_exists("res://assets/audio/horn.wav"):
		sfx_horn.stream = load("res://assets/audio/horn.wav")
	if sfx_glovebox and FileAccess.file_exists("res://assets/audio/glovebox.wav"):
		sfx_glovebox.stream = load("res://assets/audio/glovebox.wav")
	if sfx_window and FileAccess.file_exists("res://assets/audio/window_motor.wav"):
		sfx_window.stream = load("res://assets/audio/window_motor.wav")
	if sfx_wiper and FileAccess.file_exists("res://assets/audio/wiper_wipe.wav"):
		sfx_wiper.stream = load("res://assets/audio/wiper_wipe.wav")

func toggle_camera():
	is_first_person = not is_first_person
	update_camera_mode()

func update_camera_mode():
	if cam_first_person and cam_third_person:
		cam_first_person.current = is_first_person
		cam_third_person.current = not is_first_person
		print("[CarCockpit] Camara activa: ", "1ra Persona (Cabina)" if is_first_person else "3ra Persona (Exterior)")

# Acciones del Habitaculo
func trigger_ignition():
	if not VehicleState.engine_running:
		if sfx_starter:
			sfx_starter.play()
		await get_tree().create_timer(0.9).timeout
		if VehicleState.start_engine():
			if sfx_engine:
				sfx_engine.play()
	else:
		VehicleState.stop_engine()
		if sfx_engine:
			sfx_engine.stop()

func trigger_central_lock():
	if sfx_lock:
		sfx_lock.play()
	var locked = VehicleState.toggle_central_lock()
	print("[CarCockpit] Seguros centralizados: ", "CERRADOS" if locked else "ABIERTOS")

func trigger_glovebox():
	VehicleState.glovebox_open = not VehicleState.glovebox_open
	if sfx_glovebox:
		sfx_glovebox.play()
	if mesh_glovebox_door:
		mesh_glovebox_door.rotation_degrees.x = 45.0 if VehicleState.glovebox_open else 0.0
	print("[CarCockpit] Guantera: ", "ABIERTA" if VehicleState.glovebox_open else "CERRADA")

func trigger_horn():
	if sfx_horn:
		sfx_horn.play()

func trigger_dome_light():
	if sfx_click:
		sfx_click.play()
	if VehicleState.dome_light == VehicleState.DomeLightMode.OFF:
		VehicleState.dome_light = VehicleState.DomeLightMode.ON
		if light_interior: light_interior.visible = true
	else:
		VehicleState.dome_light = VehicleState.DomeLightMode.OFF
		if light_interior: light_interior.visible = false

func operate_window(win_name: String, delta_pos: float):
	if sfx_window and not sfx_window.playing:
		sfx_window.play()
	var current = 0.0
	match win_name:
		"fl": current = VehicleState.window_fl
		"fr": current = VehicleState.window_fr
		"rl": current = VehicleState.window_rl
		"rr": current = VehicleState.window_rr
	VehicleState.set_window_position(win_name, current + delta_pos)

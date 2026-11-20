extends Control

@onready var label_title = $CenterContainer/VBoxContainer/LabelTitle
@onready var label_telemetry = $TopBar/LabelTelemetry
@onready var btn_prologue = $CenterContainer/VBoxContainer/BtnPrologue
@onready var btn_roguelike = $CenterContainer/VBoxContainer/BtnRoguelike
@onready var btn_settings = $CenterContainer/VBoxContainer/BtnSettings
@onready var btn_controls = $CenterContainer/VBoxContainer/BtnControls
@onready var btn_quit = $CenterContainer/VBoxContainer/BtnQuit

var target_fps: int = 120
var current_device: String = "Xiaomi Redmi (Android 14 API 34)"

func _ready():
	# Configurar pantalla completa y tasa de refresco
	Engine.max_fps = target_fps
	update_telemetry()
	print("[Ruta 1999] Menu Principal inicializado correctamente a ", target_fps, " FPS.")

func _process(_delta):
	# Monitoreo continuo de FPS en pantalla
	var fps = Engine.get_frames_per_second()
	label_telemetry.text = "DISPOSITIVO: %s | FPS REALES: %d | OBJETIVO: %d HZ | VULKAN MOBILE" % [current_device, fps, target_fps]

func update_telemetry():
	var os_name = OS.get_name()
	if os_name == "Android":
		current_device = OS.get_model_name()

func _on_btn_prologue_pressed():
	print("[Ruta 1999] Cargando Prologo: El Garaje Nocturno...")
	# Transicion a escena del garaje
	if ResourceLoader.exists("res://scenes/garage_prologue.tscn"):
		get_tree().change_scene_to_file("res://scenes/garage_prologue.tscn")
	else:
		print("[Ruta 1999] Escena del garaje en construccion (Fase 3).")

func _on_btn_roguelike_pressed():
	print("[Ruta 1999] Modo 5 Noches en la Carretera seleccionado.")

func _on_btn_settings_pressed():
	print("[Ruta 1999] Abriendo panel de configuracion grafica Multi-SoC.")

func _on_btn_controls_pressed():
	print("[Ruta 1999] Calibrando sensores (Giroscopio / Acelerometro / Barometro).")

func _on_btn_quit_pressed():
	get_tree().quit()

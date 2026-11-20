extends Node3D
# PROLOGO: EL GARAJE DE MEDIANOCHE - RUTA 1999
# Tutorial interactivo de preparacion del vehiculo antes de salir a la carretera nocturna.

@onready var car_cockpit = $CarCockpit
@onready var label_mission = $UI/TopHUD/LabelMission
@onready var label_dialogue = $UI/DialogueBox/LabelDialogue
@onready var btn_cam_toggle = $UI/TouchHUD/BtnCamToggle
@onready var btn_ignition = $UI/TouchHUD/BtnIgnition
@onready var btn_locks = $UI/TouchHUD/BtnLocks
@onready var btn_glovebox = $UI/TouchHUD/BtnGlovebox
@onready var btn_windows = $UI/TouchHUD/BtnWindows
@onready var btn_exit_garage = $UI/TouchHUD/BtnExitGarage

enum MissionStep {
	CHECK_FLUIDS,
	ENTER_CAR,
	CHECK_GLOVEBOX,
	TEST_SYSTEMS,
	START_ENGINE,
	OPEN_GARAGE_DOOR,
	PROLOGUE_COMPLETE
}

var current_step: MissionStep = MissionStep.CHECK_FLUIDS

func _ready():
	setup_mission_ui()
	show_dialogue("Medianoche en el pueblo... Hay que revisar bien este Estima '99 antes de agarrar esa carretera.")

func setup_mission_ui():
	update_mission_label()

func update_mission_label():
	match current_step:
		MissionStep.CHECK_FLUIDS:
			label_mission.text = "OBJETIVO: Revisa los niveles de aceite y agua del radiador en el capó."
		MissionStep.ENTER_CAR:
			label_mission.text = "OBJETIVO: Acomódate en el asiento del chofer y ajusta los retrovisores."
		MissionStep.CHECK_GLOVEBOX:
			label_mission.text = "OBJETIVO: Abre la guantera y recoge la linterna pesada y el mapa."
		MissionStep.TEST_SYSTEMS:
			label_mission.text = "OBJETIVO: Prueba el seguro central y baja las ventanillas eléctricas."
		MissionStep.START_ENGINE:
			label_mission.text = "OBJETIVO: Pasa el switch y da arranque al motor 1.6L."
		MissionStep.OPEN_GARAGE_DOOR:
			label_mission.text = "OBJETIVO: Enciende los faros y sal del garaje rumbo a la Troncal."
		MissionStep.PROLOGUE_COMPLETE:
			label_mission.text = "PROLOGO COMPLETADO: Incorporándote a la Ruta Nocturna..."

func show_dialogue(text: String):
	if label_dialogue:
		label_dialogue.text = text
		print("[Prologo Diálogo] ", text)

func _on_btn_cam_toggle_pressed():
	if car_cockpit:
		car_cockpit.toggle_camera()

func _on_btn_ignition_pressed():
	if car_cockpit:
		car_cockpit.trigger_ignition()
	if current_step == MissionStep.START_ENGINE:
		show_dialogue("Ese sonido fino del 1.6L... Aguantó la chispa. Ahora a prender los faros.")
		current_step = MissionStep.OPEN_GARAGE_DOOR
		update_mission_label()
		if btn_exit_garage: btn_exit_garage.visible = true

func _on_btn_locks_pressed():
	if car_cockpit:
		car_cockpit.trigger_central_lock()
	if current_step == MissionStep.TEST_SYSTEMS:
		show_dialogue("El solenoide trancó durísimo. Bien, por si se atraviesa algún vivo en el camino.")
		current_step = MissionStep.START_ENGINE
		update_mission_label()

func _on_btn_glovebox_pressed():
	if car_cockpit:
		car_cockpit.trigger_glovebox()
	if current_step == MissionStep.CHECK_GLOVEBOX or current_step == MissionStep.CHECK_FLUIDS:
		show_dialogue("Aquí está la linterna de aluminio y el mapa arrugado... La cartera con los reales de las carreras.")
		current_step = MissionStep.TEST_SYSTEMS
		update_mission_label()

func _on_btn_windows_pressed():
	if car_cockpit:
		car_cockpit.operate_window("fl", 0.5)
	show_dialogue("Los motores eléctricos todavía suben y bajan al pelo.")

func _on_btn_exit_garage_pressed():
	current_step = MissionStep.PROLOGUE_COMPLETE
	update_mission_label()
	show_dialogue("Abriendo el portón... La neblina ya cubrió la salida. Dios nos acompañe en la ruta.")
	await get_tree().create_timer(2.0).timeout
	print("[Prologo] Transicionando al Capitulo 1: Troncal 5 / Noche 1.")

extends Control

@onready var timer: Timer = $Timer

const QTE = preload("res://Mision_4/Level 1/scenes/QTE.tscn")

var keyList = [
	{"keyString": "Q", "keyCode": KEY_Q},
	{"keyString": "E", "keyCode": KEY_E},
	{"keyString": "E", "keyCode": KEY_E},
	{"keyString": "Q", "keyCode": KEY_Q},
	{"keyString": "Q", "keyCode": KEY_Q},
	{"keyString": "E", "keyCode": KEY_E},
	{"keyString": "E", "keyCode": KEY_E},
	{"keyString": "Q", "keyCode": KEY_Q},
]

var count = 0
var keyPressedList = []
var qte_active = false  # <--- NUEVA VARIABLE

func _ready():
	timer.start()

func _on_timer_timeout() -> void:
	if qte_active:
		return  # Si hay uno activo, no crear otro
	if count >= keyList.size():
		timer.stop()
		return
	
	var keyNode = QTE.instantiate()
	keyNode.finished.connect(_on_key_finished)
	keyNode.keyCode = keyList[count].keyCode
	keyNode.keyString = keyList[count].keyString

	add_child(keyNode)
	count += 1
	qte_active = true  # Marcar como activo

func _on_key_finished(keySuccsess):
	keyPressedList.append(keySuccsess)
	qte_active = false  # Ya terminó el QTE



	
	
	
	
	
	
	
	

extends Control

@onready var ayuda1 = $help1
@onready var ayuda2 = $help2
@onready var ayuda3 = $help3

func _ready():
	ayuda1.visible = true
	ayuda2.visible = false
	ayuda3.visible = false

func _on_continue_1_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	ayuda1.visible = false
	ayuda2.visible = true
	ayuda3.visible = false
	

func _on_continue_2_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	ayuda1.visible = false
	ayuda2.visible = false
	ayuda3.visible = true
	
	
func _on_continue_3_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	SceneTransitions.change_scene_to_file("res://Mision_1/Level1/scenes/Level1.tscn")

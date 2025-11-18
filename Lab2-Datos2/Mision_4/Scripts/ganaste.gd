extends Control


func _on_continue_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	Global.index = 7
	SceneTransitions.change_scene_to_file("res://Mision_5/Etapa_3/minigame/scenes/etapa_3_inicio.tscn")
	pass # Replace with function body.

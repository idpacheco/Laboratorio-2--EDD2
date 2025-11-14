extends Control

@onready var fullscreen_btn = $Panel/Panel2/PantalllaCompleta

var is_fullscreen := false
func _ready() -> void:
	$Panel/Panel2/muisc_bar/Control/VBoxContainer/VolumeBar/musicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")))
	$Panel/Panel2/Sound_bar/Control/VBoxContainer/VolumeBar/sfxSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx")))
	# Establecer el modo de pantalla
	# Sincroniza el botón con la configuración guardada
	is_fullscreen = Settings.fullscreen_enabled
	_update_fullscreen_btn()
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
func _on_back_button_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	if Global.index ==-1:
		SceneTransitions.change_scene_to_file("res://mainMenu/Scenes/main.tscn")
	else:
		if Global.estado_des:
			SceneTransitions.change_scene_to_file("res://Map/scences/maps/question_map.tscn")
		else:
			SceneTransitions.change_scene_to_file(Global.arbol.buscar_subarbol(Global.index).dato["nombre"])
	pass # Replace with function body.


func _on_sfx_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), db)
	pass # Replace with function body.


func _on_music_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), db)
	pass # Replace with function body.


func _update_fullscreen_btn():
	if is_fullscreen:
		fullscreen_btn.texture_normal = preload("res://mainMenu/Assets/buttons/checkOn.tres")
	else:
		fullscreen_btn.texture_normal = preload("res://mainMenu/Assets/buttons/checkOff.tres")


func _on_pantallla_completa_pressed() -> void:
	is_fullscreen = !is_fullscreen
	Settings.fullscreen_enabled = is_fullscreen
	_update_fullscreen_btn()
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	pass # Replace with function body.


func _on_exite_game_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

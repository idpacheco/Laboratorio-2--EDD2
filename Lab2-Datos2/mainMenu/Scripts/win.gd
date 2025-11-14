extends CanvasLayer



func _on_texture_button_pressed() -> void:
	GameState.reset()
	SceneTransitions.change_scene_to_file("res://Level 4/scenes/level_4.tscn")
	pass # Replace with function body.

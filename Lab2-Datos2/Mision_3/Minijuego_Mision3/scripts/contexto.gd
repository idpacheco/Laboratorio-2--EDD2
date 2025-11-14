extends Control


func _on_next_to_fase_1_inst_pressed() -> void:
	get_tree().change_scene_to_file("res://Mision_3/Minijuego_Mision3/scenes/fase1_instc.tscn")


func _on_skip_pressed() -> void:
	get_tree().change_scene_to_file("res://Mision_3/Minijuego_Mision3/scenes/main_minigame_3.tscn")

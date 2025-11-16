extends Control


func _on_continue_pressed() -> void:
	Global.arbol.raiz.dato["activado"] = true
	SceneTransitions.change_scene_to_file("res://Mision_4/Scenes/Ganaste.tscn")

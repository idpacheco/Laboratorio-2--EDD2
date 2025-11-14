extends Control

func _on_back_to_game_pressed() -> void:
	get_tree().paused = false
	queue_free()

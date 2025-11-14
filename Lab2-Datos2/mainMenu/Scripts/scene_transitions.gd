extends CanvasLayer
@onready var animation_player = $AnimationPlayer
@onready var color_rect = $dissolve_rect

func change_scene_to_file(target: String) -> void:
	if animation_player:
		animation_player.play('dissolve')
		await animation_player.animation_finished
		animation_player.play_backwards('dissolve')
	else:
		print("¡No se encontró AnimationPlayer!")
	get_tree().change_scene_to_file(target)

	

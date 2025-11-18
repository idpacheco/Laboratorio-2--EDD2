extends Node2D
@onready var virus = preload("res://Mision_2/Scene/virus.tscn") 
var score=0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_virus()
	
func _process(delta: float) -> void:
	$Score.text = "Points: "+ str(score)
	if score >= 200:
		SceneTransitions.change_scene_to_file("res://Mision_2/Scene/win_2.tscn")
		AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
		AudioManager.SFXPlayer.play()
	
func add_virus():
	var instance = virus.instantiate()
	instance.position = Vector2(randf_range(50, 500), randf_range(50, 300))
	instance.connect("Gear_used", Callable(self, "spawn_new"))
	add_child(instance)
func spawn_new():
	score+=10
	add_virus()
	get_node("Snake").add_tail()

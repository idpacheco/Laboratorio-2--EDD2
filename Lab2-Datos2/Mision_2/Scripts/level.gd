extends Node2D
@onready var virus = preload("res://Mision_2/Scene/virus.tscn") 
var score=0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_virus()
	
func _process(delta: float) -> void:
	$Score.text = "Points: "+ str(score)
	
func add_virus():
	var instance = virus.instantiate()
	instance.position = Vector2(randf_range(50, 500), randf_range(50, 300))
	instance.connect("Gear_used", Callable(self, "spawn_new"))
	add_child(instance)
func spawn_new():
	score+=5
	add_virus()
	get_node("Snake").add_tail()

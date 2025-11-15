extends Control

signal finished(success: bool, elapsed: float)

@export var keyCode: Key = KEY_A
@export var eventDuration := 3
@export var displayDuration := 0.5

@onready var color_rect: ColorRect = %ColorRect
@onready var texture_rect: TextureRect = %TextureRect
@onready var success_label: Label = %SuccsessLabel

var start_time: int
var success: bool = false
var tween: Tween

func setup(image: Texture, key: Key):
	texture_rect.texture = image
	keyCode = key

func _ready() -> void:
	success_label.hide()
	success = false
	color_rect.material.set_shader_parameter("value", 1.0)
	start_time = Time.get_ticks_msec()
	await _animation()
	if not success:
		_hide_and_emit(false)

func _animation() -> void:
	tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/value", 0.0, eventDuration)
	await tween.finished

func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(keyCode) and not success_label.visible:
		success_label.show()
		if tween:
			tween.kill()
		success = true
		var elapsed = (Time.get_ticks_msec() - start_time) / 1000.0
		await get_tree().create_timer(displayDuration).timeout
		_hide_and_emit(true, elapsed)

func _hide_and_emit(success_result: bool, elapsed: float = 0.0):
	hide()
	emit_signal("finished", success_result, elapsed)

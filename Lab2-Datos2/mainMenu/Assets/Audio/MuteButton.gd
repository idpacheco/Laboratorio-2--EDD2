
extends TextureButton

const ICON_SOUND_ON = preload("res://mainMenu/Assets/buttons/muteOn.tres")
const ICON_SOUND_OFF = preload("res://mainMenu/Assets/buttons/muteOff.tres")

func _ready():
	
	update_icon()
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	AudioManager.toggle_music()
	update_icon()

func update_icon():
	if AudioManager.music_muted:
		texture_normal = ICON_SOUND_OFF
	else:
		texture_normal = ICON_SOUND_ON

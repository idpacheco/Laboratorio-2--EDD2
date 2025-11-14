extends Node2D

@onready var SFXPlayer = $SFXPlayer
@onready var MusicPlayer = $Music
var music_muted := false

func play_music(path: String) -> void:
	var music = load(path)
	if MusicPlayer.stream != music:
		MusicPlayer.stream = music
		MusicPlayer.play()

func toggle_music():
	music_muted = !music_muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), music_muted)
	

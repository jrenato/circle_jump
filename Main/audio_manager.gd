extends Node

var musics: Dictionary = {
	"LightPuzzle": preload("res://Assets/Audio/Music_Light-Puzzles.ogg"),
}

var sounds: Dictionary = {
	"Click": preload("res://Assets/Audio/menu_click.wav"),
	"Jump": preload("res://Assets/Audio/jump.ogg"),
	"Capture": preload("res://Assets/Audio/capture.ogg"),
	"Beep": preload("res://Assets/Audio/beep.ogg")
}

var master_bus: int
var music_bus: int
var sound_bus: int

@onready var music_player: AudioStreamPlayer = %MusicPlayer
@onready var sound_players: Array[AudioStreamPlayer]
@onready var sound_players_node: Node = %SoundPlayers


func _ready() -> void:
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sound_bus = AudioServer.get_bus_index("Sound")

	for sound_player in sound_players_node.get_children():
		if sound_player is AudioStreamPlayer:
			sound_players.append(sound_player)


func play_music(music_name: String) -> void:
	if music_player.stream != musics[music_name]:
		music_player.stream = musics[music_name]

	if not music_player.is_playing():
		music_player.play()


func stop_music() -> void:
	music_player.stop()


func play_sound(sound_name: String) -> void:
	for sound_player in sound_players:
		if not sound_player.is_playing():
			sound_player.stream = sounds[sound_name]
			sound_player.play()
			return


func set_music_enabled(enabled: bool) -> void:
	AudioServer.set_bus_mute(music_bus, not enabled)


func is_music_enabled() -> bool:
	return not AudioServer.is_bus_mute(music_bus)


func set_sound_enabled(enabled: bool) -> void:
	AudioServer.set_bus_mute(sound_bus, not enabled)


func is_sound_enabled() -> bool:
	return not AudioServer.is_bus_mute(sound_bus)


func set_master_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))


func set_music_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))


func set_sound_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(sound_bus, linear_to_db(value))


func _on_music_player_finished() -> void:
	# TODO: implement next track logic
	music_player.play()

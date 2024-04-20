extends CanvasLayer

signal start_game

var music_buttons = {
	true: preload("res://Assets/Images/buttons/musicOn.png"),
	false: preload("res://Assets/Images/buttons/musicOff.png")
}
var sound_buttons = {
	true: preload("res://Assets/Images/buttons/audioOn.png"),
	false: preload("res://Assets/Images/buttons/audioOff.png")
}

var fadeout_duration: float = 0.5
var current_screen: BaseScreen = null

@onready var title_screen: BaseScreen = %TitleScreen
@onready var settings_screen: BaseScreen = %SettingsScreen
@onready var game_over_screen: BaseScreen = %GameOverScreen


func _ready() -> void:
	register_buttons()
	change_screen(title_screen)


func register_buttons() -> void:
	var buttons: Array[Node] = get_tree().get_nodes_in_group("buttons")
	for button in buttons:
		if button is TextureButton:
			button.pressed.connect(_on_button_pressed.bind(button))


func change_screen(new_screen: BaseScreen) -> void:
	if current_screen:
		var disappear_tween: Tween = current_screen.disappear()
		await(disappear_tween.finished)

	if new_screen:
		current_screen = new_screen
		var appear_tween: Tween = current_screen.appear()
		await(appear_tween.finished)
		get_tree().call_group("buttons", "set_disabled", false)


func _on_button_pressed(button: TextureButton) -> void:
	AudioManager.play_sound("Click")

	match button.name:
		# Title Screen
		"PlayButton":
			change_screen(null)
			await(get_tree().create_timer(fadeout_duration).timeout)
			start_game.emit()
		"SettingsButton":
			change_screen(settings_screen)
		"QuitButton":
			get_tree().quit()

		# Settings Screen
		"SettingsBackButton":
			change_screen(title_screen)
		"MusicButton":
			AudioManager.set_music_enabled(!AudioManager.is_music_enabled())
			button.texture_normal = music_buttons[AudioManager.is_music_enabled()]
		"SoundButton":
			AudioManager.set_sound_enabled(!AudioManager.is_sound_enabled())
			button.texture_normal = sound_buttons[AudioManager.is_sound_enabled()]

		# Game Over Screen
		"HomeButton":
			change_screen(title_screen)
		"GameOverRetryButton":
			change_screen(null)
			await(get_tree().create_timer(fadeout_duration).timeout)
			start_game.emit()


func game_over() -> void:
	change_screen(game_over_screen)


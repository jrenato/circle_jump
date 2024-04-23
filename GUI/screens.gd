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
		match button.name:
			"AdsButton":
				# TODO: Implement ads
				pass
			"MusicButton":
				button.texture_normal = music_buttons[AudioManager.is_music_enabled()]
			"SoundButton":
				button.texture_normal = sound_buttons[AudioManager.is_sound_enabled()]


func change_screen(new_screen: BaseScreen) -> void:
	if current_screen:
		# We disable the buttons before the animation starts
		# so that the player can't click while the animation is playing
		get_tree().call_group("buttons", "set_disabled", true)
		var disappear_tween: Tween = current_screen.disappear()
		await(disappear_tween.finished)

	if new_screen:
		current_screen = new_screen
		var appear_tween: Tween = current_screen.appear()
		await(appear_tween.finished)
		# Only after the screen is fully appeared can we enable the buttons
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
		"BackButton":
			change_screen(title_screen)
		"MusicButton":
			AudioManager.set_music_enabled(!AudioManager.is_music_enabled())
			button.texture_normal = music_buttons[AudioManager.is_music_enabled()]
			Settings.save_settings()
		"SoundButton":
			AudioManager.set_sound_enabled(!AudioManager.is_sound_enabled())
			button.texture_normal = sound_buttons[AudioManager.is_sound_enabled()]
			Settings.save_settings()
		"AdsButton":
			# TODO: Implement ads
			pass

		# Game Over Screen
		"HomeButton":
			change_screen(title_screen)
		"RetryButton":
			change_screen(null)
			await(get_tree().create_timer(fadeout_duration).timeout)
			start_game.emit()


func game_over(score: int, high_score: int) -> void:
	change_screen(game_over_screen)

	# Update the score and highscore
	if game_over_screen.score_label:
		game_over_screen.score_label.text = "Score: %d" % score
	if game_over_screen.highscore_label:
		game_over_screen.highscore_label.text = "Best: %d" % high_score

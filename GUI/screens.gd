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
@onready var about_screen: BaseScreen = %AboutScreen


func _ready() -> void:
	DisplayServer.window_set_window_event_callback(_on_window_event)

	register_buttons()
	change_screen(title_screen)


func register_buttons() -> void:
	var buttons: Array[Node] = get_tree().get_nodes_in_group("buttons")
	for button in buttons:
		if button is BaseButton:
			button.pressed.connect(_on_button_pressed.bind(button))

		match button.name:
			"AdsButton":
				# TODO: Implement ads
				pass
			"MusicButton":
				button.texture_normal = music_buttons[AudioManager.is_music_enabled()]
				settings_screen.music_label.text = "Music " + ("On" if AudioManager.is_music_enabled() else "Off")
					
			"SoundButton":
				button.texture_normal = sound_buttons[AudioManager.is_sound_enabled()]
				settings_screen.sound_label.text = "Sound " + ("On" if AudioManager.is_sound_enabled() else "Off")


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


func game_over(score: int, high_score: int) -> void:
	change_screen(game_over_screen)

	# Update the score and highscore
	if game_over_screen.score_label:
		game_over_screen.score_label.text = "Score: %d" % score
	if game_over_screen.highscore_label:
		game_over_screen.highscore_label.text = "Best: %d" % high_score


func _on_button_pressed(button: BaseButton) -> void:
	AudioManager.play_sound("Click")

	match button.name:
		# Title Screen
		"PlayButton":
			change_screen(null)
			await(get_tree().create_timer(fadeout_duration).timeout)
			start_game.emit()
		"SettingsButton":
			change_screen(settings_screen)
		"AboutButton":
			change_screen(about_screen)
		"QuitButton":
			get_tree().quit()

		# Settings Screen
		"BackButton":
			change_screen(title_screen)
		"MusicButton":
			AudioManager.set_music_enabled(!AudioManager.is_music_enabled())
			button.texture_normal = music_buttons[AudioManager.is_music_enabled()]
			settings_screen.music_label.text = "Music " + ("On" if AudioManager.is_music_enabled() else "Off")
			Settings.save_settings()
		"SoundButton":
			AudioManager.set_sound_enabled(!AudioManager.is_sound_enabled())
			button.texture_normal = sound_buttons[AudioManager.is_sound_enabled()]
			settings_screen.sound_label.text = "Sound " + ("On" if AudioManager.is_sound_enabled() else "Off")
			Settings.save_settings()
		"AdsButton":
			# TODO: Implement ads
			if button.text == "Disable Ads":
				button.text = "Enable Ads"
			else:
				button.text = "Disable Ads"

		# Game Over Screen
		"HomeButton":
			change_screen(title_screen)
		"RetryButton":
			change_screen(null)
			await(get_tree().create_timer(fadeout_duration).timeout)
			start_game.emit()


func _on_window_event(event: int) -> void:
	match event:
		DisplayServer.WINDOW_EVENT_FOCUS_OUT:
			pass
			# TODO: Implement pause game
			# Pause game if it's in progress and not already paused
			#if game_in_progress and not get_tree().paused:
				#_on_game_pause_game()
				#Signals.add_log_msg("Lost focus, pausing the game")
		DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
			get_tree().quit()
		DisplayServer.WINDOW_EVENT_GO_BACK_REQUEST:
			match current_screen:
				settings_screen:
					change_screen(title_screen)
				game_over_screen:
					change_screen(title_screen)
				about_screen:
					change_screen(title_screen)
				title_screen:
					get_tree().quit()

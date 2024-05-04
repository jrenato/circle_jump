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

var themes: Array[String]

var ad_enabled: bool = false

@onready var title_screen: BaseScreen = %TitleScreen
@onready var pause_screen: BaseScreen = %PauseScreen
@onready var settings_screen: BaseScreen = %SettingsScreen
@onready var game_over_screen: BaseScreen = %GameOverScreen
@onready var about_screen: BaseScreen = %AboutScreen
@onready var ad_timer: Timer = %AdTimer


func _ready() -> void:
	Settings.theme_changed.connect(_on_theme_changed)

	register_buttons()
	for theme in Settings.color_schemes:
		themes.append(theme.name)
	change_screen(title_screen)
	
	settings_screen.theme_label.text = Settings.theme_name


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
				settings_screen.music_label.text = "MUSIC_" + ("ON" if AudioManager.is_music_enabled() else "OFF")

			"SoundButton":
				button.texture_normal = sound_buttons[AudioManager.is_sound_enabled()]
				settings_screen.sound_label.text = "SOUND_" + ("ON" if AudioManager.is_sound_enabled() else "OFF")


func change_screen(new_screen: BaseScreen) -> void:
	if current_screen:
		# We disable the buttons before the animation starts
		# so that the player can't click while the animation is playing
		get_tree().call_group("buttons", "set_disabled", true)
		var disappear_tween: Tween = current_screen.disappear()
		await(disappear_tween.finished)

	current_screen = new_screen

	if current_screen:
		var appear_tween: Tween = current_screen.appear()
		await(appear_tween.finished)

		# Show ad if in Game Over Screen, and no more plays before ad
		if current_screen == game_over_screen and ad_enabled:
			Settings.show_interstitial_ad()
			ad_enabled = false
			ad_timer.start()

		# Only after the screen is fully appeared can we enable the buttons
		get_tree().call_group("buttons", "set_disabled", false)


func pause_resume_game() -> void:
	if get_tree().paused:
		change_screen(null)
	else:
		change_screen(pause_screen)
		get_tree().paused = true


func game_over(score: int, high_score: int) -> void:
	change_screen(game_over_screen)

	# Update the score and highscore
	if game_over_screen.score_label:
		game_over_screen.score_label.text = str(score)
	if game_over_screen.highscore_label:
		game_over_screen.highscore_label.text = str(high_score)


func shift_theme(direction: String = "Right") -> void:
	var current_index = themes.find(Settings.theme_name)
	if current_index == -1:
		current_index = 0

	if direction == "Right":
		current_index = (current_index + 1) % themes.size()
	else:
		current_index = (current_index - 1) % themes.size()

	Settings.theme_name = themes[current_index]
	Settings.save_settings()


func _on_button_pressed(button: BaseButton) -> void:
	AudioManager.play_sound("Click")

	match button.name:
		# Title Screen
		"PlayButton":
			change_screen(null)
			await(get_tree().create_timer(fadeout_duration).timeout)
			start_game.emit()
		"TitleSettingsButton":
			change_screen(settings_screen)
		"AboutButton":
			change_screen(about_screen)
		"QuitButton":
			get_tree().quit()

		# Settings Screen
		"BackButton":
			if not get_tree().paused:
				change_screen(title_screen)
			else:
				change_screen(pause_screen)
		"MusicButton":
			AudioManager.set_music_enabled(!AudioManager.is_music_enabled())
			button.texture_normal = music_buttons[AudioManager.is_music_enabled()]
			settings_screen.music_label.text = "MUSIC_" + ("ON" if AudioManager.is_music_enabled() else "OFF")
			Settings.save_settings()
		"SoundButton":
			AudioManager.set_sound_enabled(!AudioManager.is_sound_enabled())
			button.texture_normal = sound_buttons[AudioManager.is_sound_enabled()]
			settings_screen.sound_label.text = "SOUND_" + ("ON" if AudioManager.is_sound_enabled() else "OFF")
			Settings.save_settings()
		"ThemeLeftButton":
			shift_theme("Left")
		"ThemeRightButton":
			shift_theme("Right")
		"AdsButton":
			# TODO: Implement ads
			if button.text == tr("DISABLE_ADS"):
				button.text = tr("ENABLE_ADS")
			else:
				button.text = tr("DISABLE_ADS")
			Settings.save_settings()

		# Game Over Screen
		"HomeButton":
			change_screen(title_screen)
		"RetryButton":
			change_screen(null)
			await(get_tree().create_timer(fadeout_duration).timeout)
			start_game.emit()

		# Pause Screen 
		"PauseSettingsButton":
			change_screen(settings_screen)
		"PauseHomeButton":
			get_tree().paused = false
			Settings.game_cancelled.emit()


func _on_theme_changed() -> void:
	settings_screen.theme_label.text = Settings.theme_name


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		# Handle Android back button
		match current_screen:
			title_screen:
				get_tree().quit()
			settings_screen:
				change_screen(title_screen)
			game_over_screen:
				change_screen(title_screen)
			about_screen:
				change_screen(title_screen)
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		# TODO: Implement pause game
		pass


func _on_ad_timer_timeout() -> void:
	if not ad_enabled:
		ad_enabled = true

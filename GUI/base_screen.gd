class_name BaseScreen extends Control

var fadeout_duration: float = 0.5


func _ready() -> void:
	position.x = 500


func appear() -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position:x", 0, fadeout_duration)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN_OUT)
	return tween


func disappear() -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position:x", 500, fadeout_duration)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN_OUT)
	return tween

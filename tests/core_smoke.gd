extends Node

const AimMath = preload("res://scripts/aim_math.gd")


func _ready() -> void:
	var rotated := AimMath.apply_mouse_delta(
		0.0,
		0.0,
		Vector2(10.0, -5.0),
		0.1,
		72.0
	)
	assert(is_equal_approx(rotated.x, -1.0))
	assert(is_equal_approx(rotated.y, 0.5))

	var clamped := AimMath.apply_mouse_delta(
		0.0,
		70.0,
		Vector2(0.0, -100.0),
		0.1,
		72.0
	)
	assert(is_equal_approx(clamped.y, 72.0))

	assert(is_equal_approx(AimMath.accuracy_percent(0, 0), 0.0))
	assert(is_equal_approx(AimMath.accuracy_percent(7, 10), 70.0))

	var packed := load("res://scenes/main.tscn") as PackedScene
	assert(packed != null)
	var instance := packed.instantiate()
	add_child(instance)
	await get_tree().process_frame

	assert(instance.has_method("start_training"))
	assert(instance.has_method("pause_training"))
	assert(instance.has_method("resume_training"))
	assert(instance.has_method("restart_training"))
	assert(instance.get_node("UI/StartOverlay").visible)
	assert(not instance.get_node("UI/HUD").visible)

	instance.queue_free()
	print("SKIN_AIM_CORE_SMOKE: PASS")
	get_tree().quit(0)

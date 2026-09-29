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

	assert(is_equal_approx(AimMath.valorant_degrees_per_count(0.1), 0.007))
	assert(is_equal_approx(AimMath.edpi(1600.0, 0.1), 160.0))
	assert(
		is_equal_approx(
			AimMath.cm_per_360(1600.0, 0.1),
			81.64285714285714
		)
	)
	assert(is_equal_approx(AimMath.cm_per_360(0.0, 0.1), 0.0))
	assert(is_equal_approx(AimMath.cm_per_360(1600.0, 0.0), 0.0))

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
	assert(not instance.get_node("UI/SettingsOverlay").visible)

	var dpi_input := instance.get_node(
		"UI/SettingsOverlay/Center/Content/Fields/DpiInput"
	) as SpinBox
	var sensitivity_input := instance.get_node(
		"UI/SettingsOverlay/Center/Content/Fields/SensitivityInput"
	) as SpinBox
	assert(dpi_input != null)
	assert(sensitivity_input != null)
	assert(is_equal_approx(dpi_input.value, 1600.0))
	assert(is_equal_approx(sensitivity_input.value, 0.1))

	instance.queue_free()
	print("SKIN_AIM_CORE_SMOKE: PASS")
	get_tree().quit(0)

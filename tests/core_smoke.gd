extends Node

const AimMath = preload("res://scripts/aim_math.gd")
const ValorantCrosshairCode = preload("res://scripts/valorant_crosshair_code.gd")


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

	var valorant_code := (
		"0;P;c;5;h;0;0t;1;0l;3;0v;3;0a;1;0f;0;1b;0"
	)
	var parsed_crosshair := ValorantCrosshairCode.parse(valorant_code)
	assert(parsed_crosshair["ok"])
	var parsed_profile: Dictionary = parsed_crosshair["profile"]
	assert(parsed_profile["color"] == Color("#00FFFFFF"))
	assert(not parsed_profile["outline_enabled"])
	assert(parsed_profile["inner_enabled"])
	assert(is_equal_approx(parsed_profile["inner_length_h"], 3.0))
	assert(is_equal_approx(parsed_profile["inner_length_v"], 3.0))
	assert(is_equal_approx(parsed_profile["inner_thickness"], 1.0))
	assert(is_equal_approx(parsed_profile["inner_opacity"], 1.0))
	assert(not parsed_profile["outer_enabled"])
	assert(parsed_profile["ignored_dynamic_settings"])

	var custom_crosshair := ValorantCrosshairCode.parse(
		"0;P;c;8;u;23FF23FF;h;1;o;0.6;t;2;d;1;z;3;"
		+ "0b;0;1b;1;1t;2;1l;5;1v;2;1g;1;1o;6;1a;0.75"
	)
	assert(custom_crosshair["ok"])
	var custom_profile: Dictionary = custom_crosshair["profile"]
	assert(custom_profile["color"] == Color("#23FF23FF"))
	assert(custom_profile["outline_enabled"])
	assert(is_equal_approx(custom_profile["outline_opacity"], 0.6))
	assert(is_equal_approx(custom_profile["outline_thickness"], 2.0))
	assert(custom_profile["center_dot_enabled"])
	assert(not custom_profile["inner_enabled"])
	assert(custom_profile["outer_enabled"])
	assert(is_equal_approx(custom_profile["outer_length_h"], 5.0))
	assert(is_equal_approx(custom_profile["outer_length_v"], 2.0))

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

	assert(not instance.get_node("UI/CrosshairSettingsOverlay").visible)
	assert(
		instance.get_node(
			"UI/CrosshairSettingsOverlay/Center/Content/CodeInput"
		) is LineEdit
	)
	assert(
		instance.get_node(
			"UI/CrosshairSettingsOverlay/Center/Content/ImportCodeButton"
		) is Button
	)

	var start_crosshair_button := instance.get_node(
		"UI/StartOverlay/Center/Content/CrosshairButton"
	) as Button
	assert(start_crosshair_button != null)
	assert(start_crosshair_button.visible)
	assert(not start_crosshair_button.disabled)

	var button_center := (
		start_crosshair_button.global_position
		+ start_crosshair_button.size * 0.5
	)

	var mouse_down := InputEventMouseButton.new()
	mouse_down.button_index = MOUSE_BUTTON_LEFT
	mouse_down.position = button_center
	mouse_down.global_position = button_center
	mouse_down.pressed = true
	instance.get_viewport().push_input(mouse_down, true)
	await get_tree().process_frame

	var mouse_up := InputEventMouseButton.new()
	mouse_up.button_index = MOUSE_BUTTON_LEFT
	mouse_up.position = button_center
	mouse_up.global_position = button_center
	mouse_up.pressed = false
	instance.get_viewport().push_input(mouse_up, true)
	await get_tree().process_frame

	assert(not instance.get_node("UI/StartOverlay").visible)
	assert(instance.get_node("UI/CrosshairSettingsOverlay").visible)
	assert(
		instance.get_node(
			"UI/CrosshairSettingsOverlay/Center/Content/CodeInput"
		).has_focus()
	)

	var crosshair_content := instance.get_node(
		"UI/CrosshairSettingsOverlay/Center/Content"
	) as Control
	var viewport_size := instance.get_viewport().get_visible_rect().size
	print(
		"CROSSHAIR_LAYOUT: viewport=",
		viewport_size,
		" content_rect=",
		crosshair_content.get_global_rect()
	)
	assert(crosshair_content.size.y <= viewport_size.y)

	instance._cancel_crosshair_settings()
	await get_tree().process_frame
	assert(instance.get_node("UI/StartOverlay").visible)
	assert(not instance.get_node("UI/ResultOverlay").visible)

	var timer_label := instance.get_node("UI/HUD/Timer") as Label
	var start_best_label := instance.get_node(
		"UI/StartOverlay/Center/Content/BestScore"
	) as Label
	assert(timer_label != null)
	assert(start_best_label != null)
	assert(timer_label.text == "01:00")

	instance.personal_best_score = 0
	instance.start_training()
	assert(instance.get_node("UI/HUD").visible)
	assert(not instance.get_node("UI/StartOverlay").visible)
	assert(not instance.get_node("UI/ResultOverlay").visible)
	assert(is_equal_approx(instance.session_remaining_seconds, 60.0))
	assert(timer_label.text == "01:00")

	instance._process(1.25)
	assert(instance.session_remaining_seconds < 59.0)
	assert(timer_label.text == "00:59")

	instance.pause_training()
	var paused_remaining: float = instance.session_remaining_seconds
	instance._process(5.0)
	assert(is_equal_approx(instance.session_remaining_seconds, paused_remaining))

	instance.resume_training()
	instance.score = 12
	instance.hits = 12
	instance.shots = 15
	instance.misses = 3
	instance.session_remaining_seconds = 0.01
	instance._process(0.02)
	await get_tree().process_frame

	assert(instance.run_state == instance.RunState.RESULT)
	assert(instance.get_node("UI/ResultOverlay").visible)
	assert(not instance.get_node("UI/HUD").visible)
	assert(not instance.get_node("UI/Crosshair").visible)
	assert(instance.personal_best_score == 12)
	assert(
		instance.get_node("UI/ResultOverlay/Center/Content/Title").text
		== "NEW BEST!"
	)
	assert(
		instance.get_node("UI/ResultOverlay/Center/Content/Score").text
		== "SCORE  12"
	)
	assert(
		instance.get_node("UI/ResultOverlay/Center/Content/Accuracy").text
		== "命中率  80%"
	)
	assert(
		instance.get_node("UI/ResultOverlay/Center/Content/HitsMisses").text
		== "HIT  12    MISS  3"
	)
	assert(
		instance.get_node("UI/ResultOverlay/Center/Content/Best").text
		== "BEST  12"
	)
	assert(start_best_label.text == "BEST  12")

	var records_config := ConfigFile.new()
	assert(records_config.load("user://settings.cfg") == OK)
	assert(
		int(
			records_config.get_value(
				"training_records",
				"default_best_score",
				0
			)
		) == 12
	)

	instance.start_training()
	await get_tree().process_frame
	assert(instance.run_state == instance.RunState.PLAYING)
	assert(instance.score == 0)
	assert(is_equal_approx(instance.session_remaining_seconds, 60.0))
	assert(timer_label.text == "01:00")
	assert(not instance.get_node("UI/ResultOverlay").visible)

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

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

	var settings_path := ProjectSettings.globalize_path("user://settings.cfg")
	if FileAccess.file_exists("user://settings.cfg"):
		assert(DirAccess.remove_absolute(settings_path) == OK)

	var legacy_config := ConfigFile.new()
	legacy_config.set_value("training_records", "default_best_score", 7)
	assert(legacy_config.save("user://settings.cfg") == OK)

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

	var difficulty_select := instance.get_node(
		"UI/StartOverlay/Center/Content/DifficultyRow/DifficultySelect"
	) as OptionButton
	assert(difficulty_select != null)
	assert(difficulty_select.item_count == 3)
	assert(difficulty_select.selected == 1)
	assert(instance.selected_difficulty == instance.DifficultyLevel.NORMAL)
	assert(instance.personal_best_score == 7)
	assert(
		instance.get_node("UI/StartOverlay/Center/Content/BestScore").text
		== "標準 BEST  7"
	)
	var difficulty_sphere := instance.target_mesh.mesh as SphereMesh
	assert(difficulty_sphere != null)
	assert(is_equal_approx(difficulty_sphere.radius, 0.62))

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

	var start_content := instance.get_node(
		"UI/StartOverlay/Center/Content"
	) as Control
	assert(start_content.size.y <= viewport_size.y)

	instance.start_training()
	assert(instance.get_node("UI/HUD").visible)
	assert(not instance.get_node("UI/StartOverlay").visible)
	assert(not instance.get_node("UI/ResultOverlay").visible)
	assert(is_equal_approx(instance.session_remaining_seconds, 60.0))
	assert(timer_label.text == "01:00")

	instance._process(1.25)
	assert(instance.session_remaining_seconds < 59.0)
	assert(timer_label.text == "00:59")

	instance.score = 25
	instance.pause_training()
	var paused_remaining: float = instance.session_remaining_seconds
	instance._process(5.0)
	assert(is_equal_approx(instance.session_remaining_seconds, paused_remaining))

	var pause_main_menu_button := instance.get_node(
		"UI/PauseOverlay/Center/Content/MainMenuButton"
	) as Button
	assert(pause_main_menu_button != null)
	assert(pause_main_menu_button.visible)
	assert(not pause_main_menu_button.disabled)
	var pause_content := instance.get_node(
		"UI/PauseOverlay/Center/Content"
	) as Control
	assert(pause_content.size.y <= viewport_size.y)

	pause_main_menu_button.pressed.emit()
	await get_tree().process_frame
	assert(instance.run_state == instance.RunState.READY)
	assert(instance.get_node("UI/StartOverlay").visible)
	assert(not instance.get_node("UI/PauseOverlay").visible)
	assert(not instance.get_node("UI/HUD").visible)
	assert(not instance.get_node("UI/Crosshair").visible)
	assert(not instance.target_mesh.visible)
	assert(instance.personal_best_score == 7)

	var abandon_config := ConfigFile.new()
	assert(abandon_config.load("user://settings.cfg") == OK)
	assert(
		not abandon_config.has_section_key(
			"training_records",
			"best_normal_score"
		)
	)

	instance.start_training()
	assert(instance.run_state == instance.RunState.PLAYING)
	assert(instance.score == 0)
	assert(is_equal_approx(instance.session_remaining_seconds, 60.0))
	instance.pause_training()
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
		== "標準 BEST  12"
	)
	assert(
		instance.get_node("UI/ResultOverlay/Center/Content/Duration").text
		== "標準 / 60秒 Session"
	)
	assert(start_best_label.text == "標準 BEST  12")

	var records_config := ConfigFile.new()
	assert(records_config.load("user://settings.cfg") == OK)
	assert(
		int(
			records_config.get_value(
				"training_records",
				"default_best_score",
				0
			)
		) == 7
	)
	assert(
		int(
			records_config.get_value(
				"training_records",
				"best_normal_score",
				0
			)
		) == 12
	)

	instance.start_training()
	assert(instance.run_state == instance.RunState.PLAYING)
	assert(instance.score == 0)
	assert(is_equal_approx(instance.session_remaining_seconds, 60.0))
	assert(timer_label.text == "01:00")
	assert(not instance.get_node("UI/ResultOverlay").visible)

	instance._show_ready_state()
	var sensitivity_before_difficulty: float = instance.valorant_sensitivity
	var crosshair_before_difficulty: Dictionary = instance.crosshair_profile.duplicate(true)
	difficulty_select.select(instance.DifficultyLevel.EASY)
	difficulty_select.item_selected.emit(instance.DifficultyLevel.EASY)
	assert(instance.selected_difficulty == instance.DifficultyLevel.EASY)
	assert(is_equal_approx(instance.valorant_sensitivity, sensitivity_before_difficulty))
	assert(instance.crosshair_profile == crosshair_before_difficulty)
	assert(instance.personal_best_score == 0)
	assert(start_best_label.text == "かんたん BEST  0")
	assert(is_equal_approx(difficulty_sphere.radius, 0.82))
	var target_position: Vector3 = instance.target_body.position
	assert(target_position.x >= -4.2 and target_position.x <= 4.2)
	assert(target_position.y >= 0.6 and target_position.y <= 4.2)

	var difficulty_config := ConfigFile.new()
	assert(difficulty_config.load("user://settings.cfg") == OK)
	assert(
		str(
			difficulty_config.get_value(
				"training",
				"difficulty",
				""
			)
		) == "easy"
	)

	instance.start_training()
	instance.score = 5
	instance.hits = 5
	instance.shots = 6
	instance.misses = 1
	instance.session_remaining_seconds = 0.01
	instance._process(0.02)
	assert(instance.run_state == instance.RunState.RESULT)
	assert(instance.personal_best_score == 5)
	assert(
		instance.get_node("UI/ResultOverlay/Center/Content/Best").text
		== "かんたん BEST  5"
	)

	records_config = ConfigFile.new()
	assert(records_config.load("user://settings.cfg") == OK)
	assert(
		int(
			records_config.get_value(
				"training_records",
				"best_easy_score",
				0
			)
		) == 5
	)
	assert(
		int(
			records_config.get_value(
				"training_records",
				"best_normal_score",
				0
			)
		) == 12
	)

	instance._show_ready_state()
	difficulty_select.select(instance.DifficultyLevel.HARD)
	difficulty_select.item_selected.emit(instance.DifficultyLevel.HARD)
	assert(instance.selected_difficulty == instance.DifficultyLevel.HARD)
	assert(instance.personal_best_score == 0)
	assert(start_best_label.text == "むずかしい BEST  0")
	assert(is_equal_approx(difficulty_sphere.radius, 0.46))
	assert(is_equal_approx(instance.valorant_sensitivity, sensitivity_before_difficulty))
	assert(instance.crosshair_profile == crosshair_before_difficulty)
	instance.start_training()
	assert(is_equal_approx(instance.session_remaining_seconds, 60.0))
	assert(instance.score == 0)
	instance._show_ready_state()
	target_position = instance.target_body.position
	assert(target_position.x >= -6.2 and target_position.x <= 6.2)
	assert(target_position.y >= -0.1 and target_position.y <= 5.0)

	difficulty_select.select(instance.DifficultyLevel.NORMAL)
	difficulty_select.item_selected.emit(instance.DifficultyLevel.NORMAL)
	assert(instance.selected_difficulty == instance.DifficultyLevel.NORMAL)
	assert(instance.personal_best_score == 12)
	assert(start_best_label.text == "標準 BEST  12")
	assert(is_equal_approx(difficulty_sphere.radius, 0.62))

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

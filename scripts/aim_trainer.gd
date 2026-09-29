extends Node3D

const AimMath = preload("res://scripts/aim_math.gd")

enum RunState {
	READY,
	PLAYING,
	PAUSED,
}

const TARGET_DISTANCE := 14.0
const TARGET_RADIUS := 0.62
const TARGET_X_RANGE := Vector2(-5.2, 5.2)
const TARGET_Y_RANGE := Vector2(0.2, 4.6)
const PITCH_LIMIT_DEGREES := 72.0

const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "aim"
const CROSSHAIR_SETTINGS_SECTION := "crosshair"
const DEFAULT_DPI := 1600.0
const DEFAULT_VALORANT_SENSITIVITY := 0.1
const MIN_DPI := 100.0
const MAX_DPI := 32000.0
const MIN_VALORANT_SENSITIVITY := 0.001
const MAX_VALORANT_SENSITIVITY := 10.0

const DEFAULT_CROSSHAIR_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const DEFAULT_CROSSHAIR_LENGTH := 5.0
const DEFAULT_CROSSHAIR_THICKNESS := 2.0
const DEFAULT_CROSSHAIR_GAP := 4.0
const DEFAULT_CROSSHAIR_OUTLINE := true
const DEFAULT_CROSSHAIR_CENTER_DOT := false
const DEFAULT_CROSSHAIR_DOT_SIZE := 2.0

@onready var camera: Camera3D = $Camera3D
@onready var target_root: Node3D = $TargetRoot

@onready var hud: Control = $UI/HUD
@onready var score_label: Label = $UI/HUD/Stats/Score
@onready var hit_label: Label = $UI/HUD/Stats/Hits
@onready var miss_label: Label = $UI/HUD/Stats/Misses
@onready var accuracy_label: Label = $UI/HUD/Stats/Accuracy
@onready var crosshair: AimCrosshair = $UI/Crosshair
@onready var controls_hint: Label = $UI/ControlsHint
@onready var feedback_label: Label = $UI/Feedback
@onready var feedback_timer: Timer = $FeedbackTimer

@onready var start_overlay: Control = $UI/StartOverlay
@onready var start_button: Button = $UI/StartOverlay/Center/Content/StartButton
@onready var start_sensitivity_label: Label = (
	$UI/StartOverlay/Center/Content/CurrentSensitivity
)
@onready var start_settings_button: Button = (
	$UI/StartOverlay/Center/Content/SettingsButton
)
@onready var start_crosshair_button: Button = (
	$UI/StartOverlay/Center/Content/CrosshairButton
)

@onready var pause_overlay: Control = $UI/PauseOverlay
@onready var resume_button: Button = $UI/PauseOverlay/Center/Content/ResumeButton
@onready var restart_button: Button = $UI/PauseOverlay/Center/Content/RestartButton
@onready var pause_sensitivity_label: Label = (
	$UI/PauseOverlay/Center/Content/SensitivitySummary
)
@onready var pause_settings_button: Button = (
	$UI/PauseOverlay/Center/Content/SettingsButton
)
@onready var pause_crosshair_button: Button = (
	$UI/PauseOverlay/Center/Content/CrosshairButton
)

@onready var settings_overlay: Control = $UI/SettingsOverlay
@onready var dpi_input: SpinBox = $UI/SettingsOverlay/Center/Content/Fields/DpiInput
@onready var sensitivity_input: SpinBox = (
	$UI/SettingsOverlay/Center/Content/Fields/SensitivityInput
)
@onready var settings_metrics: Label = $UI/SettingsOverlay/Center/Content/Metrics
@onready var save_settings_button: Button = (
	$UI/SettingsOverlay/Center/Content/SaveButton
)
@onready var cancel_settings_button: Button = (
	$UI/SettingsOverlay/Center/Content/CancelButton
)

@onready var crosshair_settings_overlay: Control = $UI/CrosshairSettingsOverlay
@onready var crosshair_preview: AimCrosshair = (
	$UI/CrosshairSettingsOverlay/Center/Content/PreviewArea/PreviewCrosshair
)
@onready var crosshair_color_input: ColorPickerButton = (
	$UI/CrosshairSettingsOverlay/Center/Content/Fields/ColorInput
)
@onready var crosshair_length_input: SpinBox = (
	$UI/CrosshairSettingsOverlay/Center/Content/Fields/LengthInput
)
@onready var crosshair_thickness_input: SpinBox = (
	$UI/CrosshairSettingsOverlay/Center/Content/Fields/ThicknessInput
)
@onready var crosshair_gap_input: SpinBox = (
	$UI/CrosshairSettingsOverlay/Center/Content/Fields/GapInput
)
@onready var crosshair_outline_input: CheckButton = (
	$UI/CrosshairSettingsOverlay/Center/Content/Fields/OutlineInput
)
@onready var crosshair_center_dot_input: CheckButton = (
	$UI/CrosshairSettingsOverlay/Center/Content/Fields/CenterDotInput
)
@onready var crosshair_dot_size_input: SpinBox = (
	$UI/CrosshairSettingsOverlay/Center/Content/Fields/DotSizeInput
)
@onready var save_crosshair_button: Button = (
	$UI/CrosshairSettingsOverlay/Center/Content/SaveButton
)
@onready var cancel_crosshair_button: Button = (
	$UI/CrosshairSettingsOverlay/Center/Content/CancelButton
)
@onready var crosshair_description: Label = (
	$UI/CrosshairSettingsOverlay/Center/Content/Description
)

var run_state := RunState.READY
var settings_return_state := RunState.READY
var crosshair_return_state := RunState.READY
var yaw_degrees := 0.0
var pitch_degrees := 0.0
var score := 0
var shots := 0
var hits := 0
var misses := 0

var mouse_dpi := DEFAULT_DPI
var valorant_sensitivity := DEFAULT_VALORANT_SENSITIVITY
var settings_original_dpi := DEFAULT_DPI
var settings_original_sensitivity := DEFAULT_VALORANT_SENSITIVITY

var crosshair_color := DEFAULT_CROSSHAIR_COLOR
var crosshair_length := DEFAULT_CROSSHAIR_LENGTH
var crosshair_thickness := DEFAULT_CROSSHAIR_THICKNESS
var crosshair_gap := DEFAULT_CROSSHAIR_GAP
var crosshair_outline := DEFAULT_CROSSHAIR_OUTLINE
var crosshair_center_dot := DEFAULT_CROSSHAIR_CENTER_DOT
var crosshair_dot_size := DEFAULT_CROSSHAIR_DOT_SIZE

var crosshair_original_color := DEFAULT_CROSSHAIR_COLOR
var crosshair_original_length := DEFAULT_CROSSHAIR_LENGTH
var crosshair_original_thickness := DEFAULT_CROSSHAIR_THICKNESS
var crosshair_original_gap := DEFAULT_CROSSHAIR_GAP
var crosshair_original_outline := DEFAULT_CROSSHAIR_OUTLINE
var crosshair_original_center_dot := DEFAULT_CROSSHAIR_CENTER_DOT
var crosshair_original_dot_size := DEFAULT_CROSSHAIR_DOT_SIZE

var previous_accumulated_input := true

var target_body: StaticBody3D
var target_mesh: MeshInstance3D
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	previous_accumulated_input = Input.use_accumulated_input
	Input.use_accumulated_input = false

	start_button.pressed.connect(start_training)
	start_settings_button.pressed.connect(
		func() -> void: _open_settings(RunState.READY)
	)
	start_crosshair_button.pressed.connect(
		func() -> void: _open_crosshair_settings(RunState.READY)
	)
	resume_button.pressed.connect(resume_training)
	restart_button.pressed.connect(restart_training)
	pause_settings_button.pressed.connect(
		func() -> void: _open_settings(RunState.PAUSED)
	)
	pause_crosshair_button.pressed.connect(
		func() -> void: _open_crosshair_settings(RunState.PAUSED)
	)
	save_settings_button.pressed.connect(_save_settings_and_close)
	cancel_settings_button.pressed.connect(_cancel_settings)
	dpi_input.value_changed.connect(_on_settings_value_changed)
	sensitivity_input.value_changed.connect(_on_settings_value_changed)

	save_crosshair_button.pressed.connect(_save_crosshair_settings_and_close)
	cancel_crosshair_button.pressed.connect(_cancel_crosshair_settings)
	crosshair_color_input.color_changed.connect(_on_crosshair_control_changed)
	crosshair_length_input.value_changed.connect(_on_crosshair_control_changed)
	crosshair_thickness_input.value_changed.connect(_on_crosshair_control_changed)
	crosshair_gap_input.value_changed.connect(_on_crosshair_control_changed)
	crosshair_outline_input.toggled.connect(_on_crosshair_control_changed)
	crosshair_center_dot_input.toggled.connect(_on_crosshair_control_changed)
	crosshair_dot_size_input.value_changed.connect(_on_crosshair_control_changed)

	feedback_timer.timeout.connect(_hide_feedback)

	_load_settings()
	_sync_settings_controls()
	_sync_crosshair_controls()
	_create_target()
	_show_ready_state()
	_update_hud()
	_update_sensitivity_labels()


func _exit_tree() -> void:
	Input.use_accumulated_input = previous_accumulated_input
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _unhandled_input(event: InputEvent) -> void:
	if crosshair_settings_overlay.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				_cancel_crosshair_settings()
				get_viewport().set_input_as_handled()
		return

	if settings_overlay.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				_cancel_settings()
				get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if run_state == RunState.PLAYING:
				pause_training()
			elif run_state == RunState.PAUSED:
				resume_training()
			get_viewport().set_input_as_handled()
			return

		if event.keycode == KEY_R and run_state != RunState.READY:
			restart_training()
			get_viewport().set_input_as_handled()
			return

	if run_state != RunState.PLAYING:
		return

	if event is InputEventMouseMotion:
		if event.screen_relative.is_zero_approx():
			return

		var rotation := AimMath.apply_mouse_delta(
			yaw_degrees,
			pitch_degrees,
			event.screen_relative,
			AimMath.valorant_degrees_per_count(valorant_sensitivity),
			PITCH_LIMIT_DEGREES
		)
		yaw_degrees = rotation.x
		pitch_degrees = rotation.y
		camera.rotation_degrees = Vector3(pitch_degrees, yaw_degrees, 0.0)
		get_viewport().set_input_as_handled()
		return

	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		_shoot()
		get_viewport().set_input_as_handled()


func start_training() -> void:
	_reset_round()
	run_state = RunState.PLAYING
	start_overlay.visible = false
	pause_overlay.visible = false
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false
	hud.visible = true
	crosshair.visible = true
	controls_hint.visible = true
	target_mesh.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func pause_training() -> void:
	if run_state != RunState.PLAYING:
		return

	run_state = RunState.PAUSED
	pause_overlay.visible = true
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false
	crosshair.visible = false
	controls_hint.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_update_sensitivity_labels()
	resume_button.grab_focus()


func resume_training() -> void:
	if run_state != RunState.PAUSED:
		return

	run_state = RunState.PLAYING
	pause_overlay.visible = false
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false
	crosshair.visible = true
	controls_hint.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func restart_training() -> void:
	_reset_round()
	run_state = RunState.PLAYING
	start_overlay.visible = false
	pause_overlay.visible = false
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false
	hud.visible = true
	crosshair.visible = true
	controls_hint.visible = true
	target_mesh.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_show_feedback("RESTART", Color(0.82, 0.9, 1.0))


func _show_ready_state() -> void:
	run_state = RunState.READY
	start_overlay.visible = true
	pause_overlay.visible = false
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false
	hud.visible = false
	crosshair.visible = false
	controls_hint.visible = false
	feedback_label.visible = false
	target_mesh.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_update_sensitivity_labels()
	start_button.grab_focus()


func _reset_round() -> void:
	score = 0
	shots = 0
	hits = 0
	misses = 0
	yaw_degrees = 0.0
	pitch_degrees = 0.0
	camera.rotation_degrees = Vector3.ZERO
	_move_target()
	_update_hud()


func _shoot() -> void:
	shots += 1

	var ray_from := camera.global_position
	var ray_to := ray_from + (-camera.global_transform.basis.z * 100.0)
	var query := PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	var result := get_world_3d().direct_space_state.intersect_ray(query)

	var collider = result.get("collider")
	if collider is Node and collider.is_in_group("aim_target"):
		hits += 1
		score += 1
		_move_target()
		_show_feedback("HIT +1", Color(0.42, 1.0, 0.64))
	else:
		misses += 1
		_show_feedback("MISS", Color(1.0, 0.58, 0.58))

	_update_hud()


func _create_target() -> void:
	target_body = StaticBody3D.new()
	target_body.name = "AimTarget"
	target_body.add_to_group("aim_target")
	target_root.add_child(target_body)

	target_mesh = MeshInstance3D.new()
	target_mesh.name = "Mesh"
	var sphere := SphereMesh.new()
	sphere.radius = TARGET_RADIUS
	sphere.height = TARGET_RADIUS * 2.0
	target_mesh.mesh = sphere

	var target_material := StandardMaterial3D.new()
	target_material.albedo_color = Color(1.0, 0.34, 0.32)
	target_material.emission_enabled = true
	target_material.emission = Color(0.7, 0.08, 0.07)
	target_material.emission_energy_multiplier = 1.25
	target_mesh.material_override = target_material
	target_body.add_child(target_mesh)

	var collision := CollisionShape3D.new()
	collision.name = "Collision"
	var shape := SphereShape3D.new()
	shape.radius = TARGET_RADIUS
	collision.shape = shape
	target_body.add_child(collision)

	_move_target()


func _move_target() -> void:
	if target_body == null:
		return

	target_body.position = Vector3(
		rng.randf_range(TARGET_X_RANGE.x, TARGET_X_RANGE.y),
		rng.randf_range(TARGET_Y_RANGE.x, TARGET_Y_RANGE.y),
		-TARGET_DISTANCE
	)


func _update_hud() -> void:
	score_label.text = "SCORE  %d" % score
	hit_label.text = "HIT  %d" % hits
	miss_label.text = "MISS  %d" % misses
	var accuracy := AimMath.accuracy_percent(hits, shots)
	accuracy_label.text = "命中率  %d%%" % int(round(accuracy))


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		mouse_dpi = DEFAULT_DPI
		valorant_sensitivity = DEFAULT_VALORANT_SENSITIVITY
		crosshair_color = DEFAULT_CROSSHAIR_COLOR
		crosshair_length = DEFAULT_CROSSHAIR_LENGTH
		crosshair_thickness = DEFAULT_CROSSHAIR_THICKNESS
		crosshair_gap = DEFAULT_CROSSHAIR_GAP
		crosshair_outline = DEFAULT_CROSSHAIR_OUTLINE
		crosshair_center_dot = DEFAULT_CROSSHAIR_CENTER_DOT
		crosshair_dot_size = DEFAULT_CROSSHAIR_DOT_SIZE
		return

	mouse_dpi = clampf(
		float(config.get_value(SETTINGS_SECTION, "dpi", DEFAULT_DPI)),
		MIN_DPI,
		MAX_DPI
	)
	valorant_sensitivity = clampf(
		float(
			config.get_value(
				SETTINGS_SECTION,
				"valorant_sensitivity",
				DEFAULT_VALORANT_SENSITIVITY
			)
		),
		MIN_VALORANT_SENSITIVITY,
		MAX_VALORANT_SENSITIVITY
	)

	var stored_color = config.get_value(
		CROSSHAIR_SETTINGS_SECTION,
		"color",
		DEFAULT_CROSSHAIR_COLOR
	)
	crosshair_color = (
		stored_color if stored_color is Color else DEFAULT_CROSSHAIR_COLOR
	)
	crosshair_length = clampf(
		float(
			config.get_value(
				CROSSHAIR_SETTINGS_SECTION,
				"length",
				DEFAULT_CROSSHAIR_LENGTH
			)
		),
		1.0,
		20.0
	)
	crosshair_thickness = clampf(
		float(
			config.get_value(
				CROSSHAIR_SETTINGS_SECTION,
				"thickness",
				DEFAULT_CROSSHAIR_THICKNESS
			)
		),
		1.0,
		8.0
	)
	crosshair_gap = clampf(
		float(
			config.get_value(
				CROSSHAIR_SETTINGS_SECTION,
				"gap",
				DEFAULT_CROSSHAIR_GAP
			)
		),
		0.0,
		20.0
	)
	crosshair_outline = bool(
		config.get_value(
			CROSSHAIR_SETTINGS_SECTION,
			"outline",
			DEFAULT_CROSSHAIR_OUTLINE
		)
	)
	crosshair_center_dot = bool(
		config.get_value(
			CROSSHAIR_SETTINGS_SECTION,
			"center_dot",
			DEFAULT_CROSSHAIR_CENTER_DOT
		)
	)
	crosshair_dot_size = clampf(
		float(
			config.get_value(
				CROSSHAIR_SETTINGS_SECTION,
				"dot_size",
				DEFAULT_CROSSHAIR_DOT_SIZE
			)
		),
		1.0,
		8.0
	)


func _save_settings() -> Error:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(SETTINGS_SECTION, "dpi", mouse_dpi)
	config.set_value(
		SETTINGS_SECTION,
		"valorant_sensitivity",
		valorant_sensitivity
	)
	return config.save(SETTINGS_PATH)


func _sync_settings_controls() -> void:
	dpi_input.set_value_no_signal(mouse_dpi)
	sensitivity_input.set_value_no_signal(valorant_sensitivity)
	_update_settings_preview()


func _open_settings(return_state: int) -> void:
	settings_return_state = return_state
	settings_original_dpi = mouse_dpi
	settings_original_sensitivity = valorant_sensitivity

	start_overlay.visible = false
	pause_overlay.visible = false
	crosshair_settings_overlay.visible = false
	settings_overlay.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_sync_settings_controls()
	dpi_input.grab_focus()


func _save_settings_and_close() -> void:
	mouse_dpi = clampf(dpi_input.value, MIN_DPI, MAX_DPI)
	valorant_sensitivity = clampf(
		sensitivity_input.value,
		MIN_VALORANT_SENSITIVITY,
		MAX_VALORANT_SENSITIVITY
	)

	var save_error := _save_settings()
	if save_error != OK:
		settings_metrics.text = (
			"設定を保存できませんでした。Error: %d" % save_error
		)
		return

	_update_sensitivity_labels()
	_close_settings()


func _cancel_settings() -> void:
	mouse_dpi = settings_original_dpi
	valorant_sensitivity = settings_original_sensitivity
	_sync_settings_controls()
	_update_sensitivity_labels()
	_close_settings()


func _close_settings() -> void:
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false

	if settings_return_state == RunState.PAUSED:
		run_state = RunState.PAUSED
		pause_overlay.visible = true
		resume_button.grab_focus()
	else:
		run_state = RunState.READY
		start_overlay.visible = true
		start_button.grab_focus()


func _on_settings_value_changed(_value: float) -> void:
	mouse_dpi = clampf(dpi_input.value, MIN_DPI, MAX_DPI)
	valorant_sensitivity = clampf(
		sensitivity_input.value,
		MIN_VALORANT_SENSITIVITY,
		MAX_VALORANT_SENSITIVITY
	)
	_update_settings_preview()


func _update_settings_preview() -> void:
	var current_edpi := AimMath.edpi(mouse_dpi, valorant_sensitivity)
	var cm360 := AimMath.cm_per_360(mouse_dpi, valorant_sensitivity)
	settings_metrics.text = (
		"eDPI: %.1f\ncm / 360°: %.2f cm\n"
		+ "回転係数: %.5f° / input count"
	) % [
		current_edpi,
		cm360,
		AimMath.valorant_degrees_per_count(valorant_sensitivity)
	]


func _update_sensitivity_labels() -> void:
	var current_edpi := AimMath.edpi(mouse_dpi, valorant_sensitivity)
	var summary := "%d DPI  /  VALORANT %.3f  /  %.0f eDPI" % [
		int(round(mouse_dpi)),
		valorant_sensitivity,
		current_edpi
	]
	start_sensitivity_label.text = summary
	pause_sensitivity_label.text = summary


func _save_crosshair_settings() -> Error:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(CROSSHAIR_SETTINGS_SECTION, "color", crosshair_color)
	config.set_value(CROSSHAIR_SETTINGS_SECTION, "length", crosshair_length)
	config.set_value(
		CROSSHAIR_SETTINGS_SECTION,
		"thickness",
		crosshair_thickness
	)
	config.set_value(CROSSHAIR_SETTINGS_SECTION, "gap", crosshair_gap)
	config.set_value(CROSSHAIR_SETTINGS_SECTION, "outline", crosshair_outline)
	config.set_value(
		CROSSHAIR_SETTINGS_SECTION,
		"center_dot",
		crosshair_center_dot
	)
	config.set_value(CROSSHAIR_SETTINGS_SECTION, "dot_size", crosshair_dot_size)
	return config.save(SETTINGS_PATH)


func _sync_crosshair_controls() -> void:
	crosshair_color_input.color = crosshair_color
	crosshair_length_input.set_value_no_signal(crosshair_length)
	crosshair_thickness_input.set_value_no_signal(crosshair_thickness)
	crosshair_gap_input.set_value_no_signal(crosshair_gap)
	crosshair_outline_input.set_pressed_no_signal(crosshair_outline)
	crosshair_center_dot_input.set_pressed_no_signal(crosshair_center_dot)
	crosshair_dot_size_input.set_value_no_signal(crosshair_dot_size)
	crosshair_description.text = "変更はプレビューへすぐ反映されます"
	_apply_crosshair_style()


func _open_crosshair_settings(return_state: int) -> void:
	crosshair_return_state = return_state
	crosshair_original_color = crosshair_color
	crosshair_original_length = crosshair_length
	crosshair_original_thickness = crosshair_thickness
	crosshair_original_gap = crosshair_gap
	crosshair_original_outline = crosshair_outline
	crosshair_original_center_dot = crosshair_center_dot
	crosshair_original_dot_size = crosshair_dot_size

	start_overlay.visible = false
	pause_overlay.visible = false
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_sync_crosshair_controls()
	crosshair_color_input.grab_focus()


func _save_crosshair_settings_and_close() -> void:
	_read_crosshair_controls()
	var save_error := _save_crosshair_settings()
	if save_error != OK:
		crosshair_description.text = (
			"設定を保存できませんでした。Error: %d" % save_error
		)
		return

	_apply_crosshair_style()
	_close_crosshair_settings()


func _cancel_crosshair_settings() -> void:
	crosshair_color = crosshair_original_color
	crosshair_length = crosshair_original_length
	crosshair_thickness = crosshair_original_thickness
	crosshair_gap = crosshair_original_gap
	crosshair_outline = crosshair_original_outline
	crosshair_center_dot = crosshair_original_center_dot
	crosshair_dot_size = crosshair_original_dot_size
	_sync_crosshair_controls()
	_close_crosshair_settings()


func _close_crosshair_settings() -> void:
	crosshair_settings_overlay.visible = false

	if crosshair_return_state == RunState.PAUSED:
		run_state = RunState.PAUSED
		pause_overlay.visible = true
		resume_button.grab_focus()
	else:
		run_state = RunState.READY
		start_overlay.visible = true
		start_button.grab_focus()


func _on_crosshair_control_changed(_value = null) -> void:
	_read_crosshair_controls()
	_apply_crosshair_style()


func _read_crosshair_controls() -> void:
	crosshair_color = crosshair_color_input.color
	crosshair_length = clampf(crosshair_length_input.value, 1.0, 20.0)
	crosshair_thickness = clampf(crosshair_thickness_input.value, 1.0, 8.0)
	crosshair_gap = clampf(crosshair_gap_input.value, 0.0, 20.0)
	crosshair_outline = crosshair_outline_input.button_pressed
	crosshair_center_dot = crosshair_center_dot_input.button_pressed
	crosshair_dot_size = clampf(crosshair_dot_size_input.value, 1.0, 8.0)


func _apply_crosshair_style() -> void:
	crosshair.set_style(
		crosshair_color,
		crosshair_length,
		crosshair_thickness,
		crosshair_gap,
		crosshair_outline,
		crosshair_center_dot,
		crosshair_dot_size
	)
	crosshair_preview.set_style(
		crosshair_color,
		crosshair_length,
		crosshair_thickness,
		crosshair_gap,
		crosshair_outline,
		crosshair_center_dot,
		crosshair_dot_size
	)


func _show_feedback(text: String, color: Color) -> void:
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)
	feedback_label.visible = true
	feedback_timer.start()


func _hide_feedback() -> void:
	feedback_label.visible = false

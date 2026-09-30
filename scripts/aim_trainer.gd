extends Node3D

const AimMath = preload("res://scripts/aim_math.gd")
const StageCatalog = preload("res://scripts/stage_catalog.gd")
const ValorantCrosshairCode = preload("res://scripts/valorant_crosshair_code.gd")

enum RunState {
	READY,
	PLAYING,
	PAUSED,
	RESULT,
}

enum DifficultyLevel {
	EASY,
	NORMAL,
	HARD,
}

enum TrainingMode {
	SINGLE,
	GRIDSHOT,
	HOLD_ANGLE,
	MICROSHOT,
	FLICK,
}

const TARGET_DISTANCE := 14.0
const TRAINING_MODE_KEYS := ["single", "gridshot", "hold_angle", "microshot", "flick"]
const TRAINING_MODE_LABELS := ["シングル", "Gridshot", "Hold Angle / Pre-Aim", "Microshot", "Flick"]
const TRAINING_MODE_DESCRIPTIONS := [
	"1 Targetを順番に狙う基本練習",
	"3 Targetを素早く切り替えて撃つ練習",
	"置きAimを維持し、Peek後の小さな補正を撃つ練習",
	"小さなTargetへ細かいmicro-adjustmentを繰り返す練習",
	"離れたTargetへ大きく素早くAimし、止めて撃つ練習",
]
const DEFAULT_TRAINING_MODE := TrainingMode.SINGLE
const GRIDSHOT_TARGET_COUNT := 3
const GRIDSHOT_MIN_SEPARATION_MULTIPLIER := 2.6
const HOLD_ANGLE_MIN_WAIT_SECONDS := 0.55
const HOLD_ANGLE_MAX_WAIT_SECONDS := 1.10
const HOLD_ANGLE_MARKER_RADIUS := 0.16
const HOLD_ANGLE_PEEK_OFFSETS := [1.0, 1.4, 1.8]
const HOLD_ANGLE_HEAD_HEIGHT := 1.8
const MICROSHOT_TARGET_RADII := [0.50, 0.36, 0.26]
const MICROSHOT_MAX_STEP := [0.75, 1.05, 1.35]
const MICROSHOT_CENTER_X_RANGE := Vector2(-2.4, 2.4)
const MICROSHOT_CENTER_Y_RANGE := Vector2(0.9, 3.7)
const FLICK_TARGET_RADII := [0.76, 0.56, 0.42]
const FLICK_MIN_STEP := [2.2, 3.2, 4.2]
const FLICK_CENTER_REFERENCE := Vector2(0.0, 2.0)
const DIFFICULTY_KEYS := ["easy", "normal", "hard"]
const DIFFICULTY_LABELS := ["かんたん", "標準", "むずかしい"]
const DIFFICULTY_DESCRIPTIONS := [
	"Target: 大きい  /  出現範囲: 狭い",
	"Target: 標準  /  出現範囲: 標準",
	"Target: 小さい  /  出現範囲: 広い",
]
const DIFFICULTY_TARGET_RADII := [0.82, 0.62, 0.46]
const DIFFICULTY_X_RANGES := [
	Vector2(-4.2, 4.2),
	Vector2(-5.2, 5.2),
	Vector2(-6.2, 6.2),
]
const DIFFICULTY_Y_RANGES := [
	Vector2(0.6, 4.2),
	Vector2(0.2, 4.6),
	Vector2(-0.1, 5.0),
]
const DEFAULT_DIFFICULTY := DifficultyLevel.NORMAL
const PITCH_LIMIT_DEGREES := 72.0
const SESSION_DURATION_SECONDS := 60.0

const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "aim"
const CROSSHAIR_SETTINGS_SECTION := "crosshair"
const TRAINING_SETTINGS_SECTION := "training"
const RECORDS_SECTION := "training_records"
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
@onready var timer_label: Label = $UI/HUD/Timer
@onready var crosshair: Control = $UI/Crosshair
@onready var controls_hint: Label = $UI/ControlsHint
@onready var feedback_label: Label = $UI/Feedback
@onready var feedback_timer: Timer = $FeedbackTimer

@onready var home_overlay: Control = $UI/HomeOverlay
@onready var home_stage_list: VBoxContainer = (
	$UI/HomeOverlay/Margin/Content/Body/Library/StageScroll/StageList
)
@onready var stage_title_label: Label = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/Title
)
@onready var stage_meta_label: Label = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/Meta
)
@onready var stage_tags_label: Label = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/Tags
)
@onready var stage_description_label: Label = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/Description
)
@onready var start_button: Button = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/StartButton
)
@onready var start_sensitivity_label: Label = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/CurrentSensitivity
)
@onready var start_settings_button: Button = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/SettingsActions/SettingsButton
)
@onready var start_crosshair_button: Button = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/SettingsActions/CrosshairButton
)
@onready var start_best_label: Label = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/BestScore
)
@onready var difficulty_select: OptionButton = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/DifficultySelect
)
@onready var difficulty_description: Label = (
	$UI/HomeOverlay/Margin/Content/Body/SelectedPanel/PanelMargin/Selected/DifficultyDescription
)

@onready var pause_overlay: Control = $UI/PauseOverlay
@onready var resume_button: Button = $UI/PauseOverlay/Center/Content/ResumeButton
@onready var restart_button: Button = $UI/PauseOverlay/Center/Content/RestartButton
@onready var pause_main_menu_button: Button = (
	$UI/PauseOverlay/Center/Content/MainMenuButton
)
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
@onready var crosshair_preview: Control = (
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
@onready var crosshair_code_input: LineEdit = (
	$UI/CrosshairSettingsOverlay/Center/Content/CodeInput
)
@onready var import_crosshair_code_button: Button = (
	$UI/CrosshairSettingsOverlay/Center/Content/ImportCodeButton
)
@onready var crosshair_import_status: Label = (
	$UI/CrosshairSettingsOverlay/Center/Content/ImportStatus
)

@onready var result_overlay: Control = $UI/ResultOverlay
@onready var result_title: Label = $UI/ResultOverlay/Center/Content/Title
@onready var result_score_label: Label = $UI/ResultOverlay/Center/Content/Score
@onready var result_accuracy_label: Label = (
	$UI/ResultOverlay/Center/Content/Accuracy
)
@onready var result_hits_misses_label: Label = (
	$UI/ResultOverlay/Center/Content/HitsMisses
)
@onready var result_best_label: Label = $UI/ResultOverlay/Center/Content/Best
@onready var result_mode_label: Label = $UI/ResultOverlay/Center/Content/Duration
@onready var retry_button: Button = $UI/ResultOverlay/Center/Content/RetryButton
@onready var result_back_button: Button = (
	$UI/ResultOverlay/Center/Content/BackButton
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
var session_remaining_seconds := SESSION_DURATION_SECONDS
var selected_training_mode := DEFAULT_TRAINING_MODE
var selected_difficulty := DEFAULT_DIFFICULTY
var personal_best_scores: Dictionary = {
	"single_easy": 0,
	"single_normal": 0,
	"single_hard": 0,
	"gridshot_easy": 0,
	"gridshot_normal": 0,
	"gridshot_hard": 0,
	"hold_angle_easy": 0,
	"hold_angle_normal": 0,
	"hold_angle_hard": 0,
	"microshot_easy": 0,
	"microshot_normal": 0,
	"microshot_hard": 0,
	"flick_easy": 0,
	"flick_normal": 0,
	"flick_hard": 0,
}
var personal_best_score := 0
var last_session_new_best := false

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
var crosshair_imported_code := ""
var crosshair_original_imported_code := ""
var crosshair_profile: Dictionary = {}
var crosshair_original_profile: Dictionary = {}
var crosshair_controls_syncing := false

var previous_accumulated_input := true

var target_body: StaticBody3D
var target_mesh: MeshInstance3D
var target_collision: CollisionShape3D
var target_bodies: Array = []
var target_meshes: Array = []
var target_collisions: Array = []
var hold_angle_marker: MeshInstance3D
var hold_angle_wait_remaining := 0.0
var hold_angle_target_visible := false
var hold_angle_anchor_position := Vector3.ZERO
var stages: Array = []
var home_stage_buttons: Dictionary = {}
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	previous_accumulated_input = Input.use_accumulated_input
	Input.use_accumulated_input = false

	_populate_difficulty_options()
	difficulty_select.item_selected.connect(_on_difficulty_selected)

	start_button.pressed.connect(start_training)
	start_settings_button.pressed.connect(
		func() -> void: _open_settings(RunState.READY)
	)
	start_crosshair_button.pressed.connect(
		func() -> void: _open_crosshair_settings(RunState.READY)
	)
	resume_button.pressed.connect(resume_training)
	restart_button.pressed.connect(restart_training)
	pause_main_menu_button.pressed.connect(return_to_main_menu)
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
	import_crosshair_code_button.pressed.connect(
		_import_valorant_crosshair_code
	)
	crosshair_color_input.color_changed.connect(_on_crosshair_control_changed)
	crosshair_length_input.value_changed.connect(_on_crosshair_control_changed)
	crosshair_thickness_input.value_changed.connect(_on_crosshair_control_changed)
	crosshair_gap_input.value_changed.connect(_on_crosshair_control_changed)
	crosshair_outline_input.toggled.connect(_on_crosshair_control_changed)
	crosshair_center_dot_input.toggled.connect(_on_crosshair_control_changed)
	crosshair_dot_size_input.value_changed.connect(_on_crosshair_control_changed)

	retry_button.pressed.connect(start_training)
	result_back_button.pressed.connect(_show_home)

	feedback_timer.timeout.connect(_hide_feedback)

	_load_settings()
	stages = StageCatalog.load_stages()
	_build_home_stage_list()
	_sync_settings_controls()
	_sync_crosshair_controls()
	_create_targets()
	_sync_difficulty_ui()
	_show_home()
	_update_hud()
	_update_sensitivity_labels()
	_update_best_labels()


func _process(delta: float) -> void:
	if run_state != RunState.PLAYING:
		return

	session_remaining_seconds = maxf(
		session_remaining_seconds - delta,
		0.0
	)
	_update_timer_label()

	if session_remaining_seconds <= 0.0:
		_finish_session()
		return

	_update_hold_angle(delta)


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
			elif run_state == RunState.RESULT:
				_show_home()
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
	home_overlay.visible = false
	pause_overlay.visible = false
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false
	result_overlay.visible = false
	hud.visible = true
	crosshair.visible = true
	controls_hint.visible = true
	_set_targets_active(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func pause_training() -> void:
	if run_state != RunState.PLAYING:
		return

	run_state = RunState.PAUSED
	pause_overlay.visible = true
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false
	result_overlay.visible = false
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
	result_overlay.visible = false
	crosshair.visible = true
	controls_hint.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func restart_training() -> void:
	_reset_round()
	run_state = RunState.PLAYING
	home_overlay.visible = false
	pause_overlay.visible = false
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false
	result_overlay.visible = false
	hud.visible = true
	crosshair.visible = true
	controls_hint.visible = true
	_set_targets_active(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_show_feedback("RESTART", Color(0.82, 0.9, 1.0))


func return_to_main_menu() -> void:
	if run_state != RunState.PAUSED:
		return
	_show_home()


func _show_home() -> void:
	run_state = RunState.READY
	home_overlay.visible = true
	pause_overlay.visible = false
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false
	result_overlay.visible = false
	hud.visible = false
	crosshair.visible = false
	controls_hint.visible = false
	feedback_label.visible = false
	_set_targets_active(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_sync_current_personal_best()
	_sync_home_selection_ui()
	_sync_difficulty_ui()
	_update_sensitivity_labels()
	_update_best_labels()

	var selected_button = home_stage_buttons.get(_current_mode_key())
	if selected_button is Button:
		selected_button.grab_focus()
	elif home_stage_list.get_child_count() > 0:
		var first_button := home_stage_list.get_child(0) as Button
		if first_button != null:
			first_button.grab_focus()


func _show_ready_state() -> void:
	_show_home()


func _reset_round() -> void:
	score = 0
	shots = 0
	hits = 0
	misses = 0
	session_remaining_seconds = _current_stage_duration_seconds()
	last_session_new_best = false
	yaw_degrees = 0.0
	pitch_degrees = 0.0
	camera.rotation_degrees = Vector3.ZERO
	_move_active_targets()
	_update_hud()
	_update_timer_label()


func _finish_session() -> void:
	if run_state != RunState.PLAYING:
		return

	run_state = RunState.RESULT
	session_remaining_seconds = 0.0
	_update_timer_label()

	last_session_new_best = score > personal_best_score
	if last_session_new_best:
		personal_best_score = score
		personal_best_scores[_current_record_id()] = personal_best_score
		_save_personal_best()

	hud.visible = false
	crosshair.visible = false
	controls_hint.visible = false
	feedback_label.visible = false
	_set_targets_active(false)
	pause_overlay.visible = false
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = false
	result_overlay.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var accuracy := AimMath.accuracy_percent(hits, shots)
	result_title.text = "NEW BEST!" if last_session_new_best else "RESULT"
	result_score_label.text = "SCORE  %d" % score
	result_accuracy_label.text = "命中率  %d%%" % int(round(accuracy))
	result_hits_misses_label.text = "HIT  %d    MISS  %d" % [hits, misses]
	result_best_label.text = "%s BEST  %d" % [
		_current_training_label(),
		personal_best_score,
	]
	result_mode_label.text = "%s / %d秒 Session" % [
		_current_training_label(),
		int(round(_current_stage_duration_seconds())),
	]
	_update_best_labels()
	retry_button.grab_focus()


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
		var target_index := target_bodies.find(collider)
		if target_index >= 0:
			if selected_training_mode == TrainingMode.HOLD_ANGLE:
				_prepare_hold_angle_cycle()
			elif selected_training_mode == TrainingMode.MICROSHOT:
				_move_microshot_target()
			elif selected_training_mode == TrainingMode.FLICK:
				_move_flick_target()
			else:
				_move_target_at(target_index)
		_show_feedback("HIT +1", Color(0.42, 1.0, 0.64))
	else:
		misses += 1
		_show_feedback("MISS", Color(1.0, 0.58, 0.58))

	_update_hud()


func _create_targets() -> void:
	for index in range(GRIDSHOT_TARGET_COUNT):
		var body := StaticBody3D.new()
		body.name = "AimTarget%d" % (index + 1)
		body.add_to_group("aim_target")
		target_root.add_child(body)

		var mesh := MeshInstance3D.new()
		mesh.name = "Mesh"
		mesh.mesh = SphereMesh.new()

		var target_material := StandardMaterial3D.new()
		target_material.albedo_color = Color(1.0, 0.34, 0.32)
		target_material.emission_enabled = true
		target_material.emission = Color(0.7, 0.08, 0.07)
		target_material.emission_energy_multiplier = 1.25
		mesh.material_override = target_material
		body.add_child(mesh)

		var collision := CollisionShape3D.new()
		collision.name = "Collision"
		collision.shape = SphereShape3D.new()
		body.add_child(collision)

		target_bodies.append(body)
		target_meshes.append(mesh)
		target_collisions.append(collision)

	target_body = target_bodies[0]
	target_mesh = target_meshes[0]
	target_collision = target_collisions[0]

	hold_angle_marker = MeshInstance3D.new()
	hold_angle_marker.name = "HoldAngleMarker"
	var marker_mesh := SphereMesh.new()
	marker_mesh.radius = HOLD_ANGLE_MARKER_RADIUS
	marker_mesh.height = HOLD_ANGLE_MARKER_RADIUS * 2.0
	hold_angle_marker.mesh = marker_mesh
	var marker_material := StandardMaterial3D.new()
	marker_material.albedo_color = Color(0.35, 0.72, 1.0, 0.82)
	marker_material.emission_enabled = true
	marker_material.emission = Color(0.08, 0.32, 0.72)
	marker_material.emission_energy_multiplier = 0.8
	hold_angle_marker.material_override = marker_material
	target_root.add_child(hold_angle_marker)
	hold_angle_marker.visible = false

	_apply_difficulty_to_target()
	_move_active_targets()
	_set_targets_active(false)


func _active_target_count() -> int:
	if selected_training_mode == TrainingMode.GRIDSHOT:
		return GRIDSHOT_TARGET_COUNT
	return 1


func _set_targets_active(active: bool) -> void:
	var active_count := _active_target_count()
	for index in range(target_bodies.size()):
		var should_enable := active and index < active_count
		if selected_training_mode == TrainingMode.HOLD_ANGLE and index == 0:
			should_enable = should_enable and hold_angle_target_visible
		var mesh := target_meshes[index] as MeshInstance3D
		var collision := target_collisions[index] as CollisionShape3D
		mesh.visible = should_enable
		collision.disabled = not should_enable

	if hold_angle_marker != null:
		hold_angle_marker.visible = (
			active
			and selected_training_mode == TrainingMode.HOLD_ANGLE
			and not hold_angle_target_visible
		)


func _move_target() -> void:
	_move_target_at(0)


func _move_active_targets() -> void:
	if selected_training_mode == TrainingMode.HOLD_ANGLE:
		_prepare_hold_angle_cycle()
		return
	if selected_training_mode == TrainingMode.MICROSHOT:
		_place_microshot_start()
		return
	if selected_training_mode == TrainingMode.FLICK:
		_place_flick_start()
		return
	for index in range(_active_target_count()):
		_move_target_at(index)


func _place_microshot_start() -> void:
	if target_bodies.is_empty():
		return
	var body := target_bodies[0] as StaticBody3D
	body.position = Vector3(
		rng.randf_range(-0.55, 0.55),
		rng.randf_range(1.65, 2.35),
		-TARGET_DISTANCE
	)


func _move_microshot_target() -> void:
	if target_bodies.is_empty():
		return

	var body := target_bodies[0] as StaticBody3D
	var current := body.position
	var max_step: float = MICROSHOT_MAX_STEP[selected_difficulty]
	var candidate := current

	for attempt in range(20):
		var angle := rng.randf_range(0.0, TAU)
		var distance := rng.randf_range(max_step * 0.45, max_step)
		candidate = Vector3(
			clampf(current.x + cos(angle) * distance, MICROSHOT_CENTER_X_RANGE.x, MICROSHOT_CENTER_X_RANGE.y),
			clampf(current.y + sin(angle) * distance, MICROSHOT_CENTER_Y_RANGE.x, MICROSHOT_CENTER_Y_RANGE.y),
			-TARGET_DISTANCE
		)
		if Vector2(candidate.x, candidate.y).distance_to(Vector2(current.x, current.y)) >= max_step * 0.35:
			break

	body.position = candidate


func _place_flick_start() -> void:
	_move_flick_target_from(FLICK_CENTER_REFERENCE)


func _move_flick_target() -> void:
	if target_bodies.is_empty():
		return
	var body := target_bodies[0] as StaticBody3D
	_move_flick_target_from(Vector2(body.position.x, body.position.y))


func _move_flick_target_from(reference: Vector2) -> void:
	if target_bodies.is_empty():
		return

	var x_range: Vector2 = DIFFICULTY_X_RANGES[selected_difficulty]
	var y_range: Vector2 = DIFFICULTY_Y_RANGES[selected_difficulty]
	var min_step: float = FLICK_MIN_STEP[selected_difficulty]
	var best_candidate := Vector3(reference.x, reference.y, -TARGET_DISTANCE)
	var best_distance := -1.0

	for attempt in range(40):
		var candidate := Vector3(
			rng.randf_range(x_range.x, x_range.y),
			rng.randf_range(y_range.x, y_range.y),
			-TARGET_DISTANCE
		)
		var candidate_distance := Vector2(candidate.x, candidate.y).distance_to(reference)
		if candidate_distance > best_distance:
			best_candidate = candidate
			best_distance = candidate_distance
		if candidate_distance >= min_step:
			best_candidate = candidate
			break

	var body := target_bodies[0] as StaticBody3D
	body.position = best_candidate


func _prepare_hold_angle_cycle() -> void:
	if target_bodies.is_empty():
		return

	var x_range: Vector2 = DIFFICULTY_X_RANGES[selected_difficulty]
	var y_range: Vector2 = DIFFICULTY_Y_RANGES[selected_difficulty]
	var peek_offset: float = HOLD_ANGLE_PEEK_OFFSETS[selected_difficulty]
	var anchor_min := x_range.x + peek_offset
	var anchor_max := x_range.y - peek_offset
	if anchor_min > anchor_max:
		anchor_min = x_range.x
		anchor_max = x_range.y

	var anchor_x := rng.randf_range(anchor_min, anchor_max)
	var anchor_y := clampf(HOLD_ANGLE_HEAD_HEIGHT, y_range.x, y_range.y)
	hold_angle_anchor_position = Vector3(anchor_x, anchor_y, -TARGET_DISTANCE)

	var direction := -1.0 if rng.randi_range(0, 1) == 0 else 1.0
	var body := target_bodies[0] as StaticBody3D
	body.position = hold_angle_anchor_position + Vector3(
		peek_offset * direction,
		0.0,
		0.0
	)

	if hold_angle_marker != null:
		hold_angle_marker.position = hold_angle_anchor_position

	hold_angle_wait_remaining = rng.randf_range(
		HOLD_ANGLE_MIN_WAIT_SECONDS,
		HOLD_ANGLE_MAX_WAIT_SECONDS
	)
	hold_angle_target_visible = false
	if run_state == RunState.PLAYING:
		_set_targets_active(true)


func _update_hold_angle(delta: float) -> void:
	if selected_training_mode != TrainingMode.HOLD_ANGLE:
		return
	if hold_angle_target_visible:
		return

	hold_angle_wait_remaining = maxf(hold_angle_wait_remaining - delta, 0.0)
	if hold_angle_wait_remaining > 0.0:
		return

	hold_angle_target_visible = true
	_set_targets_active(true)


func _move_target_at(index: int) -> void:
	if index < 0 or index >= target_bodies.size():
		return

	var x_range: Vector2 = DIFFICULTY_X_RANGES[selected_difficulty]
	var y_range: Vector2 = DIFFICULTY_Y_RANGES[selected_difficulty]
	var radius: float = DIFFICULTY_TARGET_RADII[selected_difficulty]
	var minimum_separation := radius * GRIDSHOT_MIN_SEPARATION_MULTIPLIER
	var candidate := Vector3.ZERO

	for attempt in range(20):
		candidate = Vector3(
			rng.randf_range(x_range.x, x_range.y),
			rng.randf_range(y_range.x, y_range.y),
			-TARGET_DISTANCE
		)
		var overlaps := false
		for other_index in range(_active_target_count()):
			if other_index == index:
				continue
			var other_body := target_bodies[other_index] as StaticBody3D
			if other_body.position.z > -TARGET_DISTANCE * 0.5:
				continue
			var candidate_xy := Vector2(candidate.x, candidate.y)
			var other_xy := Vector2(
				other_body.position.x,
				other_body.position.y
			)
			if candidate_xy.distance_to(other_xy) < minimum_separation:
				overlaps = true
				break
		if not overlaps:
			break

	var body := target_bodies[index] as StaticBody3D
	body.position = candidate


func _apply_difficulty_to_target() -> void:
	var radius: float = DIFFICULTY_TARGET_RADII[selected_difficulty]
	if selected_training_mode == TrainingMode.MICROSHOT:
		radius = MICROSHOT_TARGET_RADII[selected_difficulty]
	elif selected_training_mode == TrainingMode.FLICK:
		radius = FLICK_TARGET_RADII[selected_difficulty]
	for index in range(target_meshes.size()):
		var mesh := target_meshes[index] as MeshInstance3D
		var sphere := mesh.mesh as SphereMesh
		if sphere != null:
			sphere.radius = radius
			sphere.height = radius * 2.0

		var collision := target_collisions[index] as CollisionShape3D
		var shape := collision.shape as SphereShape3D
		if shape != null:
			shape.radius = radius


func _update_hud() -> void:
	score_label.text = "SCORE  %d" % score
	hit_label.text = "HIT  %d" % hits
	miss_label.text = "MISS  %d" % misses
	var accuracy := AimMath.accuracy_percent(hits, shots)
	accuracy_label.text = "命中率  %d%%" % int(round(accuracy))


func _update_timer_label() -> void:
	var total_seconds := maxi(int(ceil(session_remaining_seconds)), 0)
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func _current_mode_key() -> String:
	return TRAINING_MODE_KEYS[selected_training_mode]


func _current_stage() -> Dictionary:
	return StageCatalog.find_by_mode(stages, _current_mode_key())


func _current_mode_label() -> String:
	var stage := _current_stage()
	if not stage.is_empty():
		return str(stage.get("title", TRAINING_MODE_LABELS[selected_training_mode]))
	return TRAINING_MODE_LABELS[selected_training_mode]


func _current_stage_duration_seconds() -> float:
	var stage := _current_stage()
	return maxf(
		float(stage.get("duration_seconds", SESSION_DURATION_SECONDS)),
		1.0
	)


func _mode_from_key(key: String) -> int:
	var index := TRAINING_MODE_KEYS.find(key)
	if index < 0:
		return DEFAULT_TRAINING_MODE
	return index


func _current_record_id() -> String:
	return "%s_%s" % [_current_mode_key(), _current_difficulty_key()]


func _current_training_label() -> String:
	return "%s / %s" % [_current_mode_label(), _current_difficulty_label()]


func _best_for_mode(mode_key: String) -> int:
	var record_id := "%s_%s" % [mode_key, _current_difficulty_key()]
	return maxi(int(personal_best_scores.get(record_id, 0)), 0)


func _build_home_stage_list() -> void:
	home_stage_buttons.clear()
	for child in home_stage_list.get_children():
		child.queue_free()

	for stage in stages:
		if not stage is Dictionary or not bool(stage.get("playable", true)):
			continue

		var mode_key := str(stage.get("mode", ""))
		if not TRAINING_MODE_KEYS.has(mode_key):
			continue

		var button := Button.new()
		button.name = "Stage_%s" % str(stage.get("id", mode_key))
		button.custom_minimum_size = Vector2(0, 68)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.toggle_mode = true
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_open_stage.bind(mode_key))
		home_stage_list.add_child(button)
		home_stage_buttons[mode_key] = button

	if home_stage_buttons.is_empty():
		var empty_button := Button.new()
		empty_button.text = "シナリオ情報を読み込めませんでした"
		empty_button.disabled = true
		empty_button.custom_minimum_size = Vector2(0, 70)
		home_stage_list.add_child(empty_button)

	_refresh_home_stage_buttons()


func _refresh_home_stage_buttons() -> void:
	for stage in stages:
		if not stage is Dictionary:
			continue

		var mode_key := str(stage.get("mode", ""))
		var button = home_stage_buttons.get(mode_key)
		if not button is Button:
			continue

		var title := str(stage.get("title", mode_key))
		var category := str(stage.get("category", "その他"))
		var duration := maxi(int(stage.get("duration_seconds", 60)), 1)
		var best := _best_for_mode(mode_key)
		button.text = "%s\n%s  ·  %ds  ·  %s PB %d" % [
			title,
			category,
			duration,
			_current_difficulty_label(),
			best,
		]
		button.set_pressed_no_signal(mode_key == _current_mode_key())


func _open_stage(mode_key: String) -> void:
	if not TRAINING_MODE_KEYS.has(mode_key):
		return

	var stage := StageCatalog.find_by_mode(stages, mode_key)
	if stage.is_empty() or not bool(stage.get("playable", true)):
		return

	selected_training_mode = _mode_from_key(mode_key)
	_sync_current_personal_best()
	_apply_difficulty_to_target()
	_move_active_targets()
	_set_targets_active(false)
	var save_error := _save_training_settings()
	_sync_home_selection_ui()
	_sync_difficulty_ui()
	_update_sensitivity_labels()

	if save_error != OK:
		difficulty_description.text = (
			"シナリオ選択を保存できませんでした。Error: %d" % save_error
		)


func _sync_home_selection_ui() -> void:
	var stage := _current_stage()
	var title := _current_mode_label()
	var category := str(stage.get("category", "SCENARIO"))
	var description := str(stage.get("description", ""))
	var duration := int(round(_current_stage_duration_seconds()))
	var tag_labels := PackedStringArray()
	for tag in stage.get("tags", []):
		tag_labels.append(str(tag).to_upper())

	stage_title_label.text = title
	stage_meta_label.text = "%s  ·  %ds" % [category, duration]
	stage_tags_label.text = (
		"TAGS  ·  %s" % "  /  ".join(tag_labels)
		if not tag_labels.is_empty()
		else "TAGS  ·  -"
	)
	stage_description_label.text = description
	start_button.text = "PLAY SCENARIO  ·  %ds" % duration


func _populate_difficulty_options() -> void:
	difficulty_select.clear()
	for label in DIFFICULTY_LABELS:
		difficulty_select.add_item(label)


func _current_difficulty_key() -> String:
	return DIFFICULTY_KEYS[selected_difficulty]


func _current_difficulty_label() -> String:
	return DIFFICULTY_LABELS[selected_difficulty]


func _difficulty_from_key(key: String) -> int:
	var index := DIFFICULTY_KEYS.find(key)
	if index < 0:
		return DEFAULT_DIFFICULTY
	return index


func _sync_current_personal_best() -> void:
	personal_best_score = maxi(
		int(personal_best_scores.get(_current_record_id(), 0)),
		0
	)


func _sync_difficulty_ui() -> void:
	difficulty_select.select(selected_difficulty)
	difficulty_description.text = _current_difficulty_description()
	_sync_current_personal_best()
	_update_best_labels()


func _current_difficulty_description() -> String:
	if selected_training_mode == TrainingMode.HOLD_ANGLE:
		return "Target %.2f  /  Peek %.1f  /  %s" % [
			DIFFICULTY_TARGET_RADII[selected_difficulty],
			HOLD_ANGLE_PEEK_OFFSETS[selected_difficulty],
			_current_difficulty_label(),
		]
	if selected_training_mode == TrainingMode.MICROSHOT:
		return "Target %.2f  /  最大移動 %.2f  /  中央寄り" % [
			MICROSHOT_TARGET_RADII[selected_difficulty],
			MICROSHOT_MAX_STEP[selected_difficulty],
		]
	if selected_training_mode == TrainingMode.FLICK:
		return "Target %.2f  /  最低移動 %.1f  /  %s範囲" % [
			FLICK_TARGET_RADII[selected_difficulty],
			FLICK_MIN_STEP[selected_difficulty],
			_current_difficulty_label(),
		]
	return DIFFICULTY_DESCRIPTIONS[selected_difficulty]


func _on_difficulty_selected(index: int) -> void:
	if index < 0 or index >= DIFFICULTY_KEYS.size():
		return
	if run_state != RunState.READY:
		_sync_difficulty_ui()
		return

	selected_difficulty = index
	_sync_current_personal_best()
	_apply_difficulty_to_target()
	_move_active_targets()
	_set_targets_active(false)
	_update_best_labels()
	difficulty_description.text = _current_difficulty_description()

	var save_error := _save_training_settings()
	if save_error != OK:
		difficulty_description.text = (
			"難易度を保存できませんでした。Error: %d" % save_error
		)


func _update_best_labels() -> void:
	start_best_label.text = "%s BEST  %d" % [
		_current_training_label(),
		personal_best_score,
	]
	_refresh_home_stage_buttons()


func _save_training_settings() -> Error:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(
		TRAINING_SETTINGS_SECTION,
		"difficulty",
		_current_difficulty_key()
	)
	config.set_value(
		TRAINING_SETTINGS_SECTION,
		"mode",
		_current_mode_key()
	)
	return config.save(SETTINGS_PATH)


func _current_best_config_key() -> String:
	if selected_training_mode == TrainingMode.GRIDSHOT:
		return "best_gridshot_%s_score" % _current_difficulty_key()
	if selected_training_mode == TrainingMode.HOLD_ANGLE:
		return "best_hold_angle_%s_score" % _current_difficulty_key()
	if selected_training_mode == TrainingMode.MICROSHOT:
		return "best_microshot_%s_score" % _current_difficulty_key()
	if selected_training_mode == TrainingMode.FLICK:
		return "best_flick_%s_score" % _current_difficulty_key()
	return "best_%s_score" % _current_difficulty_key()


func _save_personal_best() -> Error:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(
		RECORDS_SECTION,
		_current_best_config_key(),
		personal_best_score
	)
	return config.save(SETTINGS_PATH)


func _load_settings() -> void:
	var config := ConfigFile.new()
	var load_error := config.load(SETTINGS_PATH)

	if load_error != OK:
		mouse_dpi = DEFAULT_DPI
		valorant_sensitivity = DEFAULT_VALORANT_SENSITIVITY
		crosshair_color = DEFAULT_CROSSHAIR_COLOR
		crosshair_length = DEFAULT_CROSSHAIR_LENGTH
		crosshair_thickness = DEFAULT_CROSSHAIR_THICKNESS
		crosshair_gap = DEFAULT_CROSSHAIR_GAP
		crosshair_outline = DEFAULT_CROSSHAIR_OUTLINE
		crosshair_center_dot = DEFAULT_CROSSHAIR_CENTER_DOT
		crosshair_dot_size = DEFAULT_CROSSHAIR_DOT_SIZE
		crosshair_imported_code = ""
		crosshair_profile = _manual_crosshair_profile()
		selected_training_mode = DEFAULT_TRAINING_MODE
		selected_difficulty = DEFAULT_DIFFICULTY
		_sync_current_personal_best()
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
	crosshair_imported_code = str(
		config.get_value(
			CROSSHAIR_SETTINGS_SECTION,
			"valorant_code",
			""
		)
	).strip_edges()

	if not crosshair_imported_code.is_empty():
		var parsed := ValorantCrosshairCode.parse(crosshair_imported_code)
		if bool(parsed.get("ok", false)):
			crosshair_profile = parsed["profile"]
			_profile_to_manual_values(crosshair_profile)
		else:
			crosshair_imported_code = ""
			crosshair_profile = _manual_crosshair_profile()
	else:
		crosshair_profile = _manual_crosshair_profile()

	selected_training_mode = _mode_from_key(
		str(
			config.get_value(
				TRAINING_SETTINGS_SECTION,
				"mode",
				TRAINING_MODE_KEYS[DEFAULT_TRAINING_MODE]
			)
		)
	)
	selected_difficulty = _difficulty_from_key(
		str(
			config.get_value(
				TRAINING_SETTINGS_SECTION,
				"difficulty",
				DIFFICULTY_KEYS[DEFAULT_DIFFICULTY]
			)
		)
	)

	var legacy_normal_best := maxi(
		int(config.get_value(RECORDS_SECTION, "default_best_score", 0)),
		0
	)
	personal_best_scores["single_easy"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_easy_score", 0)),
		0
	)
	personal_best_scores["single_normal"] = maxi(
		int(
			config.get_value(
				RECORDS_SECTION,
				"best_normal_score",
				legacy_normal_best
			)
		),
		0
	)
	personal_best_scores["single_hard"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_hard_score", 0)),
		0
	)
	personal_best_scores["gridshot_easy"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_gridshot_easy_score", 0)),
		0
	)
	personal_best_scores["gridshot_normal"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_gridshot_normal_score", 0)),
		0
	)
	personal_best_scores["gridshot_hard"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_gridshot_hard_score", 0)),
		0
	)
	personal_best_scores["hold_angle_easy"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_hold_angle_easy_score", 0)),
		0
	)
	personal_best_scores["hold_angle_normal"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_hold_angle_normal_score", 0)),
		0
	)
	personal_best_scores["hold_angle_hard"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_hold_angle_hard_score", 0)),
		0
	)
	personal_best_scores["microshot_easy"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_microshot_easy_score", 0)),
		0
	)
	personal_best_scores["microshot_normal"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_microshot_normal_score", 0)),
		0
	)
	personal_best_scores["microshot_hard"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_microshot_hard_score", 0)),
		0
	)
	personal_best_scores["flick_easy"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_flick_easy_score", 0)),
		0
	)
	personal_best_scores["flick_normal"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_flick_normal_score", 0)),
		0
	)
	personal_best_scores["flick_hard"] = maxi(
		int(config.get_value(RECORDS_SECTION, "best_flick_hard_score", 0)),
		0
	)
	_sync_current_personal_best()


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
	home_overlay.visible = false
	settings_original_dpi = mouse_dpi
	settings_original_sensitivity = valorant_sensitivity

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
		home_overlay.visible = true
		_sync_home_selection_ui()
		_update_sensitivity_labels()
		_update_best_labels()
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
	config.set_value(
		CROSSHAIR_SETTINGS_SECTION,
		"valorant_code",
		crosshair_imported_code
	)
	return config.save(SETTINGS_PATH)


func _sync_crosshair_controls() -> void:
	crosshair_controls_syncing = true
	crosshair_color_input.color = crosshair_color
	crosshair_length_input.set_value_no_signal(crosshair_length)
	crosshair_thickness_input.set_value_no_signal(crosshair_thickness)
	crosshair_gap_input.set_value_no_signal(crosshair_gap)
	crosshair_outline_input.set_pressed_no_signal(crosshair_outline)
	crosshair_center_dot_input.set_pressed_no_signal(crosshair_center_dot)
	crosshair_dot_size_input.set_value_no_signal(crosshair_dot_size)
	crosshair_code_input.text = crosshair_imported_code
	crosshair_controls_syncing = false

	crosshair_description.text = "変更はプレビューへすぐ反映されます"
	if crosshair_imported_code.is_empty():
		crosshair_import_status.text = (
			"VALORANTのCrosshair Profile Codeを貼り付けて読み込めます。"
		)
	else:
		crosshair_import_status.text = (
			"VALORANTコード読込済み。手動項目を変更すると簡易設定へ切り替わります。"
		)

	_apply_crosshair_profile()


func _open_crosshair_settings(return_state: int) -> void:
	crosshair_return_state = return_state
	home_overlay.visible = false
	crosshair_original_color = crosshair_color
	crosshair_original_length = crosshair_length
	crosshair_original_thickness = crosshair_thickness
	crosshair_original_gap = crosshair_gap
	crosshair_original_outline = crosshair_outline
	crosshair_original_center_dot = crosshair_center_dot
	crosshair_original_dot_size = crosshair_dot_size
	crosshair_original_imported_code = crosshair_imported_code
	crosshair_original_profile = crosshair_profile.duplicate(true)

	pause_overlay.visible = false
	settings_overlay.visible = false
	crosshair_settings_overlay.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_sync_crosshair_controls()
	crosshair_code_input.grab_focus()


func _save_crosshair_settings_and_close() -> void:
	if crosshair_imported_code.is_empty():
		_read_crosshair_controls()
		crosshair_profile = _manual_crosshair_profile()

	var save_error := _save_crosshair_settings()
	if save_error != OK:
		crosshair_description.text = (
			"設定を保存できませんでした。Error: %d" % save_error
		)
		return

	_apply_crosshair_profile()
	_close_crosshair_settings()


func _cancel_crosshair_settings() -> void:
	crosshair_color = crosshair_original_color
	crosshair_length = crosshair_original_length
	crosshair_thickness = crosshair_original_thickness
	crosshair_gap = crosshair_original_gap
	crosshair_outline = crosshair_original_outline
	crosshair_center_dot = crosshair_original_center_dot
	crosshair_dot_size = crosshair_original_dot_size
	crosshair_imported_code = crosshair_original_imported_code
	crosshair_profile = crosshair_original_profile.duplicate(true)
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
		home_overlay.visible = true
		_sync_home_selection_ui()
		_update_best_labels()
		start_button.grab_focus()


func _import_valorant_crosshair_code() -> void:
	var code := crosshair_code_input.text.strip_edges()
	var parsed := ValorantCrosshairCode.parse(code)
	if not bool(parsed.get("ok", false)):
		crosshair_import_status.text = str(
			parsed.get("error", "Crosshair Codeを読み込めませんでした。")
		)
		return

	crosshair_imported_code = code
	crosshair_profile = parsed["profile"]
	_profile_to_manual_values(crosshair_profile)
	_sync_crosshair_controls()

	if bool(crosshair_profile.get("ignored_dynamic_settings", false)):
		crosshair_import_status.text = (
			"Primary Crosshairを読み込みました。Movement / Firing Errorの動的変形は"
			+ "Aim Trainerでは固定表示として扱います。"
		)
	else:
		crosshair_import_status.text = "Primary Crosshairを読み込みました。"


func _on_crosshair_control_changed(_value = null) -> void:
	if crosshair_controls_syncing:
		return

	_read_crosshair_controls()
	crosshair_imported_code = ""
	crosshair_profile = _manual_crosshair_profile()
	crosshair_import_status.text = (
		"手動調整中。VALORANTコードをもう一度読み込むと、そのProfileへ戻せます。"
	)
	_apply_crosshair_profile()


func _read_crosshair_controls() -> void:
	crosshair_color = crosshair_color_input.color
	crosshair_length = clampf(crosshair_length_input.value, 1.0, 20.0)
	crosshair_thickness = clampf(crosshair_thickness_input.value, 1.0, 8.0)
	crosshair_gap = clampf(crosshair_gap_input.value, 0.0, 20.0)
	crosshair_outline = crosshair_outline_input.button_pressed
	crosshair_center_dot = crosshair_center_dot_input.button_pressed
	crosshair_dot_size = clampf(crosshair_dot_size_input.value, 1.0, 8.0)


func _manual_crosshair_profile() -> Dictionary:
	var profile := ValorantCrosshairCode.default_profile()
	profile["color"] = crosshair_color
	profile["outline_enabled"] = crosshair_outline
	profile["center_dot_enabled"] = crosshair_center_dot
	profile["center_dot_size"] = crosshair_dot_size
	profile["inner_enabled"] = true
	profile["inner_opacity"] = 1.0
	profile["inner_length_h"] = crosshair_length
	profile["inner_length_v"] = crosshair_length
	profile["inner_vertical_independent"] = false
	profile["inner_thickness"] = crosshair_thickness
	profile["inner_offset"] = crosshair_gap
	profile["outer_enabled"] = false
	profile["source_code"] = ""
	profile["ignored_dynamic_settings"] = false
	return profile


func _profile_to_manual_values(profile: Dictionary) -> void:
	crosshair_color = profile.get("color", DEFAULT_CROSSHAIR_COLOR)
	crosshair_outline = bool(
		profile.get("outline_enabled", DEFAULT_CROSSHAIR_OUTLINE)
	)
	crosshair_center_dot = bool(
		profile.get("center_dot_enabled", DEFAULT_CROSSHAIR_CENTER_DOT)
	)
	crosshair_dot_size = float(
		profile.get("center_dot_size", DEFAULT_CROSSHAIR_DOT_SIZE)
	)

	var prefix := "inner"
	if not bool(profile.get("inner_enabled", true)) and bool(
		profile.get("outer_enabled", false)
	):
		prefix = "outer"

	crosshair_length = float(
		profile.get("%s_length_h" % prefix, DEFAULT_CROSSHAIR_LENGTH)
	)
	crosshair_thickness = maxf(
		float(
			profile.get(
				"%s_thickness" % prefix,
				DEFAULT_CROSSHAIR_THICKNESS
			)
		),
		1.0
	)
	crosshair_gap = float(
		profile.get("%s_offset" % prefix, DEFAULT_CROSSHAIR_GAP)
	)


func _apply_crosshair_profile() -> void:
	if crosshair_profile.is_empty():
		crosshair_profile = _manual_crosshair_profile()

	crosshair.set_profile(crosshair_profile)
	crosshair_preview.set_profile(crosshair_profile)


func _show_feedback(text: String, color: Color) -> void:
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)
	feedback_label.visible = true
	feedback_timer.start()


func _hide_feedback() -> void:
	feedback_label.visible = false

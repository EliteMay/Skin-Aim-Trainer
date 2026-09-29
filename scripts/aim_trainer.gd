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
const MOUSE_DEGREES_PER_PIXEL := 0.08
const PITCH_LIMIT_DEGREES := 72.0

@onready var camera: Camera3D = $Camera3D
@onready var target_root: Node3D = $TargetRoot

@onready var hud: Control = $UI/HUD
@onready var score_label: Label = $UI/HUD/Stats/Score
@onready var hit_label: Label = $UI/HUD/Stats/Hits
@onready var miss_label: Label = $UI/HUD/Stats/Misses
@onready var accuracy_label: Label = $UI/HUD/Stats/Accuracy
@onready var crosshair: Label = $UI/Crosshair
@onready var controls_hint: Label = $UI/ControlsHint
@onready var feedback_label: Label = $UI/Feedback
@onready var feedback_timer: Timer = $FeedbackTimer

@onready var start_overlay: Control = $UI/StartOverlay
@onready var start_button: Button = $UI/StartOverlay/Center/Content/StartButton

@onready var pause_overlay: Control = $UI/PauseOverlay
@onready var resume_button: Button = $UI/PauseOverlay/Center/Content/ResumeButton
@onready var restart_button: Button = $UI/PauseOverlay/Center/Content/RestartButton

var run_state := RunState.READY
var yaw_degrees := 0.0
var pitch_degrees := 0.0
var score := 0
var shots := 0
var hits := 0
var misses := 0

var target_body: StaticBody3D
var target_mesh: MeshInstance3D
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	start_button.pressed.connect(start_training)
	resume_button.pressed.connect(resume_training)
	restart_button.pressed.connect(restart_training)
	feedback_timer.timeout.connect(_hide_feedback)

	_create_target()
	_show_ready_state()
	_update_hud()


func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _unhandled_input(event: InputEvent) -> void:
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
		var rotation := AimMath.apply_mouse_delta(
			yaw_degrees,
			pitch_degrees,
			event.relative,
			MOUSE_DEGREES_PER_PIXEL,
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
	crosshair.visible = false
	controls_hint.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	resume_button.grab_focus()


func resume_training() -> void:
	if run_state != RunState.PAUSED:
		return

	run_state = RunState.PLAYING
	pause_overlay.visible = false
	crosshair.visible = true
	controls_hint.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func restart_training() -> void:
	_reset_round()
	run_state = RunState.PLAYING
	start_overlay.visible = false
	pause_overlay.visible = false
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
	hud.visible = false
	crosshair.visible = false
	controls_hint.visible = false
	feedback_label.visible = false
	target_mesh.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
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


func _show_feedback(text: String, color: Color) -> void:
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)
	feedback_label.visible = true
	feedback_timer.start()


func _hide_feedback() -> void:
	feedback_label.visible = false

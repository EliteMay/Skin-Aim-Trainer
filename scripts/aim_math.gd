class_name AimMath
extends RefCounted

const VALORANT_YAW_DEGREES_PER_COUNT := 0.07


static func apply_mouse_delta(
	yaw_degrees: float,
	pitch_degrees: float,
	relative: Vector2,
	degrees_per_input_unit: float,
	pitch_limit_degrees: float
) -> Vector2:
	var next_yaw := yaw_degrees - relative.x * degrees_per_input_unit
	var next_pitch := clampf(
		pitch_degrees - relative.y * degrees_per_input_unit,
		-pitch_limit_degrees,
		pitch_limit_degrees
	)
	return Vector2(next_yaw, next_pitch)


static func valorant_degrees_per_count(sensitivity: float) -> float:
	return maxf(sensitivity, 0.0) * VALORANT_YAW_DEGREES_PER_COUNT


static func edpi(dpi: float, sensitivity: float) -> float:
	return maxf(dpi, 0.0) * maxf(sensitivity, 0.0)


static func cm_per_360(dpi: float, sensitivity: float) -> float:
	if dpi <= 0.0 or sensitivity <= 0.0:
		return 0.0

	return (
		360.0
		/ (VALORANT_YAW_DEGREES_PER_COUNT * sensitivity * dpi)
		* 2.54
	)


static func accuracy_percent(hits: int, shots: int) -> float:
	if shots <= 0:
		return 0.0
	return float(hits) / float(shots) * 100.0

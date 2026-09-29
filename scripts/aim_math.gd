class_name AimMath
extends RefCounted


static func apply_mouse_delta(
	yaw_degrees: float,
	pitch_degrees: float,
	relative: Vector2,
	degrees_per_pixel: float,
	pitch_limit_degrees: float
) -> Vector2:
	var next_yaw := yaw_degrees - relative.x * degrees_per_pixel
	var next_pitch := clampf(
		pitch_degrees - relative.y * degrees_per_pixel,
		-pitch_limit_degrees,
		pitch_limit_degrees
	)
	return Vector2(next_yaw, next_pitch)


static func accuracy_percent(hits: int, shots: int) -> float:
	if shots <= 0:
		return 0.0
	return float(hits) / float(shots) * 100.0

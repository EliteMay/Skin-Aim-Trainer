class_name AimCrosshair
extends Control

var profile := {
	"color": Color(1.0, 1.0, 1.0, 1.0),
	"outline_enabled": true,
	"outline_opacity": 0.5,
	"outline_thickness": 1.0,
	"center_dot_enabled": false,
	"center_dot_opacity": 1.0,
	"center_dot_size": 2.0,
	"inner_enabled": true,
	"inner_opacity": 1.0,
	"inner_length_h": 5.0,
	"inner_length_v": 5.0,
	"inner_vertical_independent": false,
	"inner_thickness": 2.0,
	"inner_offset": 4.0,
	"outer_enabled": false,
	"outer_opacity": 1.0,
	"outer_length_h": 2.0,
	"outer_length_v": 2.0,
	"outer_vertical_independent": false,
	"outer_thickness": 2.0,
	"outer_offset": 10.0,
}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func set_profile(new_profile: Dictionary) -> void:
	for key in profile.keys():
		if new_profile.has(key):
			profile[key] = new_profile[key]
	queue_redraw()


func set_style(
	new_color: Color,
	new_line_length: float,
	new_line_thickness: float,
	new_gap: float,
	new_outline_enabled: bool,
	new_center_dot_enabled: bool,
	new_center_dot_size: float
) -> void:
	set_profile({
		"color": new_color,
		"outline_enabled": new_outline_enabled,
		"center_dot_enabled": new_center_dot_enabled,
		"center_dot_size": maxf(new_center_dot_size, 1.0),
		"inner_enabled": true,
		"inner_opacity": 1.0,
		"inner_length_h": maxf(new_line_length, 0.0),
		"inner_length_v": maxf(new_line_length, 0.0),
		"inner_vertical_independent": false,
		"inner_thickness": maxf(new_line_thickness, 1.0),
		"inner_offset": maxf(new_gap, 0.0),
		"outer_enabled": false,
	})


func _draw() -> void:
	var center := size * 0.5
	_draw_line_set(
		center,
		"inner",
		Color(profile["color"], float(profile["inner_opacity"]))
	)
	_draw_line_set(
		center,
		"outer",
		Color(profile["color"], float(profile["outer_opacity"]))
	)
	_draw_center_dot(center)


func _draw_line_set(center: Vector2, prefix: String, line_color: Color) -> void:
	if not bool(profile["%s_enabled" % prefix]):
		return

	var h_length := float(profile["%s_length_h" % prefix])
	var v_length := float(profile["%s_length_v" % prefix])
	var thickness := float(profile["%s_thickness" % prefix])
	var offset := float(profile["%s_offset" % prefix])

	if h_length <= 0.0 and v_length <= 0.0:
		return

	var horizontal := [
		[
			center + Vector2(-(offset + h_length), 0.0),
			center + Vector2(-offset, 0.0)
		],
		[
			center + Vector2(offset, 0.0),
			center + Vector2(offset + h_length, 0.0)
		],
	]
	var vertical := [
		[
			center + Vector2(0.0, -(offset + v_length)),
			center + Vector2(0.0, -offset)
		],
		[
			center + Vector2(0.0, offset),
			center + Vector2(0.0, offset + v_length)
		],
	]

	for segment in horizontal:
		_draw_segment(segment[0], segment[1], line_color, thickness)
	for segment in vertical:
		_draw_segment(segment[0], segment[1], line_color, thickness)


func _draw_segment(
	from: Vector2,
	to: Vector2,
	line_color: Color,
	thickness: float
) -> void:
	if bool(profile["outline_enabled"]):
		var outline_alpha := float(profile["outline_opacity"])
		var outline_color := Color(0.0, 0.0, 0.0, outline_alpha)
		draw_line(
			from,
			to,
			outline_color,
			thickness + float(profile["outline_thickness"]) * 2.0,
			false
		)

	draw_line(from, to, line_color, maxf(thickness, 1.0), false)


func _draw_center_dot(center: Vector2) -> void:
	if not bool(profile["center_dot_enabled"]):
		return

	var dot_size := maxf(float(profile["center_dot_size"]), 1.0)
	var dot_rect := Rect2(
		center - Vector2.ONE * dot_size * 0.5,
		Vector2.ONE * dot_size
	)

	if bool(profile["outline_enabled"]):
		var outline_color := Color(
			0.0,
			0.0,
			0.0,
			float(profile["outline_opacity"])
		)
		draw_rect(
			dot_rect.grow(float(profile["outline_thickness"])),
			outline_color,
			true
		)

	var dot_color := Color(
		profile["color"],
		float(profile["center_dot_opacity"])
	)
	draw_rect(dot_rect, dot_color, true)

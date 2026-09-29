class_name AimCrosshair
extends Control

var crosshair_color := Color(1.0, 1.0, 1.0, 1.0)
var line_length := 5.0
var line_thickness := 2.0
var gap := 4.0
var outline_enabled := true
var outline_width := 1.0
var center_dot_enabled := false
var center_dot_size := 2.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	crosshair_color = new_color
	line_length = maxf(new_line_length, 1.0)
	line_thickness = maxf(new_line_thickness, 1.0)
	gap = maxf(new_gap, 0.0)
	outline_enabled = new_outline_enabled
	center_dot_enabled = new_center_dot_enabled
	center_dot_size = maxf(new_center_dot_size, 1.0)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var half_thickness := line_thickness * 0.5

	var segments := [
		[
			center + Vector2(-(gap + line_length), 0.0),
			center + Vector2(-gap, 0.0)
		],
		[
			center + Vector2(gap, 0.0),
			center + Vector2(gap + line_length, 0.0)
		],
		[
			center + Vector2(0.0, -(gap + line_length)),
			center + Vector2(0.0, -gap)
		],
		[
			center + Vector2(0.0, gap),
			center + Vector2(0.0, gap + line_length)
		]
	]

	if outline_enabled:
		var outline_color := Color(0.0, 0.0, 0.0, 0.95)
		for segment in segments:
			draw_line(
				segment[0],
				segment[1],
				outline_color,
				line_thickness + outline_width * 2.0,
				false
			)

	for segment in segments:
		draw_line(
			segment[0],
			segment[1],
			crosshair_color,
			line_thickness,
			false
		)

	if center_dot_enabled:
		var dot_rect := Rect2(
			center - Vector2.ONE * center_dot_size * 0.5,
			Vector2.ONE * center_dot_size
		)
		if outline_enabled:
			draw_rect(
				dot_rect.grow(outline_width),
				Color(0.0, 0.0, 0.0, 0.95),
				true
			)
		draw_rect(dot_rect, crosshair_color, true)

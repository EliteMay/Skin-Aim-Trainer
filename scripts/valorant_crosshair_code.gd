class_name ValorantCrosshairCode
extends RefCounted

const PRESET_COLORS := {
	0: Color("#FFFFFFFF"),
	1: Color("#00FF00FF"),
	2: Color("#BFFF00FF"),
	3: Color("#DFFF00FF"),
	4: Color("#FFFF00FF"),
	5: Color("#00FFFFFF"),
	6: Color("#FF00FFFF"),
	7: Color("#FF0000FF"),
}


static func default_profile() -> Dictionary:
	return {
		"color": PRESET_COLORS[0],
		"outline_enabled": true,
		"outline_opacity": 0.5,
		"outline_thickness": 1.0,
		"center_dot_enabled": false,
		"center_dot_opacity": 1.0,
		"center_dot_size": 2.0,
		"inner_enabled": true,
		"inner_opacity": 0.8,
		"inner_length_h": 6.0,
		"inner_length_v": 6.0,
		"inner_vertical_independent": false,
		"inner_thickness": 2.0,
		"inner_offset": 3.0,
		"outer_enabled": true,
		"outer_opacity": 0.35,
		"outer_length_h": 2.0,
		"outer_length_v": 2.0,
		"outer_vertical_independent": false,
		"outer_thickness": 2.0,
		"outer_offset": 10.0,
		"source_code": "",
		"ignored_dynamic_settings": false,
	}


static func parse(code: String) -> Dictionary:
	var normalized := code.strip_edges()
	if normalized.is_empty():
		return {"ok": false, "error": "クロスヘアコードが空です。"}

	var tokens := normalized.split(";", false)
	var primary_index := -1
	for index in range(tokens.size()):
		if tokens[index] == "P":
			primary_index = index
			break

	if primary_index < 0:
		return {
			"ok": false,
			"error": "Primary Crosshairを表す「P」Sectionが見つかりません。",
		}

	var profile := default_profile()
	profile["source_code"] = normalized

	var settings := {}
	var i := primary_index + 1
	while i < tokens.size():
		var key := tokens[i]
		if key == "A" or key == "S" or key == "P":
			break
		if i + 1 >= tokens.size():
			break
		settings[key] = tokens[i + 1]
		i += 2

	_apply_color(profile, settings)
	profile["outline_enabled"] = _bool_value(
		settings, "h", profile["outline_enabled"]
	)
	profile["outline_opacity"] = _float_value(
		settings, "o", profile["outline_opacity"], 0.0, 1.0
	)
	profile["outline_thickness"] = _float_value(
		settings, "t", profile["outline_thickness"], 1.0, 6.0
	)
	profile["center_dot_enabled"] = _bool_value(
		settings, "d", profile["center_dot_enabled"]
	)
	profile["center_dot_opacity"] = _float_value(
		settings, "a", profile["center_dot_opacity"], 0.0, 1.0
	)
	profile["center_dot_size"] = _float_value(
		settings, "z", profile["center_dot_size"], 1.0, 6.0
	)

	_apply_line_set(profile, settings, "inner", "0")
	_apply_line_set(profile, settings, "outer", "1")

	for dynamic_key in [
		"f", "m", "s",
		"0m", "0s", "0f", "0e",
		"1m", "1s", "1f", "1e",
	]:
		if settings.has(dynamic_key):
			profile["ignored_dynamic_settings"] = true
			break

	return {"ok": true, "profile": profile}


static func _apply_color(profile: Dictionary, settings: Dictionary) -> void:
	var preset := _int_value(settings, "c", 0, 0, 8)
	if preset == 8 or settings.has("u"):
		var custom := str(settings.get("u", "FFFFFFFF"))
		if custom.length() == 6:
			custom += "FF"
		if custom.length() == 8 and custom.is_valid_hex_number():
			profile["color"] = Color(custom)
			return

	profile["color"] = PRESET_COLORS.get(preset, PRESET_COLORS[0])


static func _apply_line_set(
	profile: Dictionary,
	settings: Dictionary,
	name: String,
	prefix: String
) -> void:
	profile["%s_enabled" % name] = _bool_value(
		settings,
		"%sb" % prefix,
		profile["%s_enabled" % name]
	)
	profile["%s_opacity" % name] = _float_value(
		settings,
		"%sa" % prefix,
		profile["%s_opacity" % name],
		0.0,
		1.0
	)
	profile["%s_length_h" % name] = _float_value(
		settings,
		"%sl" % prefix,
		profile["%s_length_h" % name],
		0.0,
		20.0
	)
	profile["%s_vertical_independent" % name] = _bool_value(
		settings,
		"%sg" % prefix,
		profile["%s_vertical_independent" % name]
	)
	profile["%s_length_v" % name] = _float_value(
		settings,
		"%sv" % prefix,
		profile["%s_length_h" % name],
		0.0,
		20.0
	)
	if not profile["%s_vertical_independent" % name]:
		profile["%s_length_v" % name] = profile["%s_length_h" % name]

	profile["%s_thickness" % name] = _float_value(
		settings,
		"%st" % prefix,
		profile["%s_thickness" % name],
		0.0,
		10.0
	)
	profile["%s_offset" % name] = _float_value(
		settings,
		"%so" % prefix,
		profile["%s_offset" % name],
		0.0,
		20.0
	)


static func _bool_value(
	settings: Dictionary,
	key: String,
	default_value: bool
) -> bool:
	if not settings.has(key):
		return default_value
	return str(settings[key]) != "0"


static func _float_value(
	settings: Dictionary,
	key: String,
	default_value: float,
	minimum: float,
	maximum: float
) -> float:
	if not settings.has(key):
		return default_value
	var text := str(settings[key])
	if not text.is_valid_float():
		return default_value
	return clampf(text.to_float(), minimum, maximum)


static func _int_value(
	settings: Dictionary,
	key: String,
	default_value: int,
	minimum: int,
	maximum: int
) -> int:
	if not settings.has(key):
		return default_value
	var text := str(settings[key])
	if not text.is_valid_int():
		return default_value
	return clampi(text.to_int(), minimum, maximum)

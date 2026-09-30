extends RefCounted

const SCHEMA_VERSION := 1
const DEFAULT_SCENARIO_DIR := "res://data/scenarios"
const DEFAULT_PROFILE_ROOT := "res://data/profiles"


static func load_catalog(
	scenario_dir: String = DEFAULT_SCENARIO_DIR,
	profile_root: String = DEFAULT_PROFILE_ROOT
) -> Dictionary:
	var result := {
		"scenarios": [],
		"errors": [],
		"source_found": false,
	}

	var dir := DirAccess.open(scenario_dir)
	if dir == null:
		return result

	var file_names: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".json"):
			file_names.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	file_names.sort()

	if file_names.is_empty():
		return result

	result["source_found"] = true
	var scenarios: Array = []
	var errors: Array = []
	var seen_ids: Dictionary = {}

	for name in file_names:
		var path := "%s/%s" % [scenario_dir.trim_suffix("/"), name]
		var parsed_result := _read_json_dictionary(path)
		if not bool(parsed_result.get("ok", false)):
			errors.append(_error(path, "", str(parsed_result.get("error", "JSONを読み込めませんでした"))))
			continue

		var raw: Dictionary = parsed_result["value"]
		var validation_errors := validate_definition(raw, path, profile_root)
		if not validation_errors.is_empty():
			errors.append_array(validation_errors)
			continue

		var scenario := _normalize_definition(raw, path)
		var scenario_id := str(scenario.get("id", ""))
		if seen_ids.has(scenario_id):
			errors.append(_error(path, scenario_id, "Scenario idが重複しています"))
			continue

		seen_ids[scenario_id] = true
		scenarios.append(scenario)

	scenarios.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			var order_a := int(a.get("sort_order", 0))
			var order_b := int(b.get("sort_order", 0))
			if order_a == order_b:
				return str(a.get("title", "")) < str(b.get("title", ""))
			return order_a < order_b
	)

	result["scenarios"] = scenarios
	result["errors"] = errors
	return result


static func validate_definition(
	raw: Dictionary,
	source_path: String = "<memory>",
	profile_root: String = DEFAULT_PROFILE_ROOT
) -> Array:
	var errors: Array = []
	var scenario_id := str(raw.get("id", "")).strip_edges()

	if int(raw.get("schema_version", 0)) != SCHEMA_VERSION:
		errors.append(_error(source_path, scenario_id, "schema_versionは1である必要があります"))

	for key in ["id", "title", "aim_type", "player_profile", "weapon_profile", "scoring"]:
		if str(raw.get(key, "")).strip_edges().is_empty():
			errors.append(_error(source_path, scenario_id, "%sが空です" % key))

	var duration := int(raw.get("duration_seconds", 0))
	if duration <= 0:
		errors.append(_error(source_path, scenario_id, "duration_secondsは1以上である必要があります"))

	var tags_value = raw.get("tags", null)
	if not tags_value is Array:
		errors.append(_error(source_path, scenario_id, "tagsはArrayである必要があります"))
	else:
		for tag in tags_value:
			if not tag is String or str(tag).strip_edges().is_empty():
				errors.append(_error(source_path, scenario_id, "tagsには空でない文字列だけを指定してください"))
				break

	var bot_profiles_value = raw.get("bot_profiles", null)
	if not bot_profiles_value is Array or bot_profiles_value.is_empty():
		errors.append(_error(source_path, scenario_id, "bot_profilesは1件以上必要です"))
	else:
		for bot_profile in bot_profiles_value:
			if not bot_profile is String or str(bot_profile).strip_edges().is_empty():
				errors.append(_error(source_path, scenario_id, "bot_profilesには空でない文字列だけを指定してください"))
				break

	var challenge_value = raw.get("challenge", null)
	if not challenge_value is Dictionary:
		errors.append(_error(source_path, scenario_id, "challengeはDictionaryである必要があります"))
	else:
		var max_active_bots := int(challenge_value.get("max_active_bots", 0))
		if max_active_bots <= 0:
			errors.append(_error(source_path, scenario_id, "challenge.max_active_botsは1以上必要です"))
		if str(challenge_value.get("respawn", "")).strip_edges().is_empty():
			errors.append(_error(source_path, scenario_id, "challenge.respawnが空です"))

	var runtime_adapter := str(raw.get("runtime_adapter", "")).strip_edges()
	if runtime_adapter == "legacy_mode" and str(raw.get("legacy_mode", "")).strip_edges().is_empty():
		errors.append(_error(source_path, scenario_id, "legacy_mode adapterにはlegacy_modeが必要です"))

	var profile_refs := [
		["players", str(raw.get("player_profile", "")).strip_edges(), "player_profile"],
		["weapons", str(raw.get("weapon_profile", "")).strip_edges(), "weapon_profile"],
		["scoring", str(raw.get("scoring", "")).strip_edges(), "scoring"],
	]
	for ref in profile_refs:
		if not str(ref[1]).is_empty() and not _profile_exists(profile_root, str(ref[0]), str(ref[1])):
			errors.append(_error(source_path, scenario_id, "%sのProfileが見つかりません: %s" % [str(ref[2]), str(ref[1])]))

	if bot_profiles_value is Array:
		for bot_profile in bot_profiles_value:
			var bot_id := str(bot_profile).strip_edges()
			if not bot_id.is_empty() and not _profile_exists(profile_root, "bots", bot_id):
				errors.append(_error(source_path, scenario_id, "bot_profileが見つかりません: %s" % bot_id))

	return errors


static func to_legacy_stages(scenarios: Array) -> Array:
	var stages: Array = []
	for scenario in scenarios:
		if not scenario is Dictionary:
			continue
		if str(scenario.get("runtime_adapter", "")) != "legacy_mode":
			continue

		var legacy_mode := str(scenario.get("legacy_mode", "")).strip_edges()
		if legacy_mode.is_empty():
			continue

		stages.append({
			"id": str(scenario.get("id", "")),
			"mode": legacy_mode,
			"title": str(scenario.get("title", "")),
			"category": str(scenario.get("category", scenario.get("aim_type", "Scenario"))),
			"description": str(scenario.get("description", "")),
			"duration_seconds": int(scenario.get("duration_seconds", 60)),
			"playable": bool(scenario.get("playable", true)),
			"sort_order": int(scenario.get("sort_order", 0)),
			"tags": scenario.get("tags", []),
			"scenario_id": str(scenario.get("id", "")),
			"aim_type": str(scenario.get("aim_type", "")),
		})
	return stages


static func error_summary(errors: Array, max_items: int = 2) -> String:
	if errors.is_empty():
		return ""

	var messages: Array[String] = []
	var limit := mini(errors.size(), maxi(max_items, 1))
	for index in range(limit):
		var entry = errors[index]
		if entry is Dictionary:
			messages.append(str(entry.get("message", "不明なError")))
		else:
			messages.append(str(entry))

	if errors.size() > limit:
		messages.append("ほか%d件" % (errors.size() - limit))
	return " / ".join(messages)


static func _normalize_definition(raw: Dictionary, source_path: String) -> Dictionary:
	var tags: Array = []
	for tag in raw.get("tags", []):
		tags.append(str(tag).strip_edges())

	var bots: Array = []
	for bot in raw.get("bot_profiles", []):
		bots.append(str(bot).strip_edges())

	return {
		"schema_version": SCHEMA_VERSION,
		"id": str(raw.get("id", "")).strip_edges(),
		"title": str(raw.get("title", "")).strip_edges(),
		"aim_type": str(raw.get("aim_type", "")).strip_edges(),
		"category": str(raw.get("category", raw.get("aim_type", "Scenario"))).strip_edges(),
		"description": str(raw.get("description", "")).strip_edges(),
		"duration_seconds": maxi(int(raw.get("duration_seconds", 60)), 1),
		"tags": tags,
		"player_profile": str(raw.get("player_profile", "")).strip_edges(),
		"weapon_profile": str(raw.get("weapon_profile", "")).strip_edges(),
		"bot_profiles": bots,
		"challenge": raw.get("challenge", {}).duplicate(true),
		"scoring": str(raw.get("scoring", "")).strip_edges(),
		"runtime_adapter": str(raw.get("runtime_adapter", "")).strip_edges(),
		"legacy_mode": str(raw.get("legacy_mode", "")).strip_edges(),
		"playable": bool(raw.get("playable", true)),
		"sort_order": int(raw.get("sort_order", 0)),
		"source_path": source_path,
	}


static func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "error": "Fileが見つかりません"}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "Fileを開けません"}

	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {"ok": false, "error": "RootはJSON Objectである必要があります"}
	return {"ok": true, "value": parsed}


static func _profile_exists(profile_root: String, profile_type: String, profile_id: String) -> bool:
	var path := "%s/%s/%s.json" % [
		profile_root.trim_suffix("/"),
		profile_type,
		profile_id,
	]
	return FileAccess.file_exists(path)


static func _error(path: String, scenario_id: String, message: String) -> Dictionary:
	return {
		"path": path,
		"scenario_id": scenario_id,
		"message": message,
	}

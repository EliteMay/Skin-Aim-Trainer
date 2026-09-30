extends RefCounted

const DEFAULT_PATH := "res://data/stages.json"


static func load_stages(path: String = DEFAULT_PATH) -> Array:
	if not FileAccess.file_exists(path):
		return []

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return []

	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Array:
		return []

	var stages: Array = []
	var seen_ids: Dictionary = {}

	for raw_stage in parsed:
		if not raw_stage is Dictionary:
			continue

		var stage := _normalize_stage(raw_stage)
		var stage_id := str(stage.get("id", ""))
		if stage_id.is_empty() or seen_ids.has(stage_id):
			continue

		seen_ids[stage_id] = true
		stages.append(stage)

	stages.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return int(a.get("sort_order", 0)) < int(b.get("sort_order", 0))
	)
	return stages


static func find_by_mode(stages: Array, mode_key: String) -> Dictionary:
	for stage in stages:
		if stage is Dictionary and str(stage.get("mode", "")) == mode_key:
			return stage
	return {}


static func _normalize_stage(raw_stage: Dictionary) -> Dictionary:
	var tags_value = raw_stage.get("tags", [])
	var tags: Array = tags_value if tags_value is Array else []

	return {
		"id": str(raw_stage.get("id", "")).strip_edges(),
		"mode": str(raw_stage.get("mode", "")).strip_edges(),
		"title": str(raw_stage.get("title", "")).strip_edges(),
		"category": str(raw_stage.get("category", "その他")).strip_edges(),
		"description": str(raw_stage.get("description", "")).strip_edges(),
		"duration_seconds": maxi(
			int(raw_stage.get("duration_seconds", 60)),
			1
		),
		"playable": bool(raw_stage.get("playable", true)),
		"sort_order": int(raw_stage.get("sort_order", 0)),
		"tags": tags,
	}

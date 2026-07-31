extends Camera2D

@export var target_path: NodePath
@export var zoom_level: Vector2 = Vector2(0.85, 0.85)


func _ready() -> void:
	zoom = zoom_level


func _process(_delta: float) -> void:
	var target := get_node_or_null(target_path)
	if target:
		global_position = target.global_position

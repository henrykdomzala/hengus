extends ColorRect

## Darkens everything outside a circular vision radius around the player.

@export var player_path: NodePath = ^"../../Player"
@export var vision_radius_world: float = 300.0
@export var softness_world: float = 35.0

@onready var player: Node2D = get_node(player_path)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_update_shader_params()


func _process(_delta: float) -> void:
	_update_shader_params()


func _update_shader_params() -> void:
	if player == null or material == null:
		return

	var canvas_xform := get_viewport().get_canvas_transform()
	var screen_pos := canvas_xform * player.global_position
	var screen_edge := canvas_xform * (player.global_position + Vector2(vision_radius_world, 0.0))
	var radius_screen := screen_pos.distance_to(screen_edge)
	var softness_screen := softness_world * (radius_screen / maxf(vision_radius_world, 0.001))

	var mat := material as ShaderMaterial
	mat.set_shader_parameter("player_px", screen_pos)
	mat.set_shader_parameter("viewport_size", get_viewport_rect().size)
	mat.set_shader_parameter("vision_radius", radius_screen)
	mat.set_shader_parameter("softness", softness_screen)

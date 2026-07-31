extends CharacterBody2D

## Top-down movement with smooth wall sliding on walkable floor.

@export var move_speed: float = 340.0
@export var walkable_path: NodePath = ^"../WalkableMap"
@export var foot_offset: Vector2 = Vector2(0, 6)
@export var slide_iterations: int = 3

@onready var sprite: Sprite2D = $Sprite2D
@onready var walkable: WalkableMap = get_node(walkable_path)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir == Vector2.ZERO:
		velocity = Vector2.ZERO
		return

	_update_facing(input_dir)
	velocity = input_dir.normalized() * move_speed
	_move_and_slide_walkable(velocity * delta)


func _move_and_slide_walkable(motion: Vector2) -> void:
	var remaining := motion

	for _i in slide_iterations:
		if remaining.length_squared() < 0.0001:
			break

		var traveled := _move_as_far_as_possible(remaining)
		remaining -= traveled

		if remaining.length_squared() < 0.0001:
			break

		# Slide along the wall instead of stopping hard.
		var feet := global_position + foot_offset
		var normal := walkable.estimate_wall_normal(feet)
		if normal == Vector2.ZERO:
			# Fallback: try axis-aligned slides.
			_try_axis_slide(remaining)
			break

		remaining = remaining.slide(normal)

		# Tiny nudge out of the wall so we don't stick in corners.
		var nudge := -normal * 0.5
		if walkable.can_stand_at(global_position + foot_offset + nudge):
			global_position += nudge


func _move_as_far_as_possible(motion: Vector2) -> Vector2:
	if walkable.can_stand_at(global_position + motion + foot_offset):
		global_position += motion
		return motion

	var low := 0.0
	var high := 1.0
	var best := 0.0

	for _i in 10:
		var mid := (low + high) * 0.5
		if walkable.can_stand_at(global_position + motion * mid + foot_offset):
			best = mid
			low = mid
		else:
			high = mid

	var traveled := motion * best
	global_position += traveled
	return traveled


func _try_axis_slide(remaining: Vector2) -> void:
	if absf(remaining.x) > 0.001:
		_move_as_far_as_possible(Vector2(remaining.x, 0.0))
	if absf(remaining.y) > 0.001:
		_move_as_far_as_possible(Vector2(0.0, remaining.y))


func _update_facing(direction: Vector2) -> void:
	if absf(direction.x) > absf(direction.y):
		sprite.scale.x = -1.0 if direction.x < 0.0 else 1.0

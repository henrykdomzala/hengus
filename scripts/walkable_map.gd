extends Node

class_name WalkableMap

## Samples the station map image to decide where the player can stand.

@export_file("*.png", "*.webp", "*.jpg", "*.jpeg") var map_image_path: String = "res://assets/maps/station_map.png"
@export var map_sprite_path: NodePath = ^"../Map"
@export var brightness_threshold: float = 0.22
## Preferred spawn search center (cafeteria on Skeld map).
@export var preferred_spawn: Vector2i = Vector2i(300, 280)
## How many pixels to expand walkable floor (helps narrow doorways).
@export_range(0, 4) var floor_expand: int = 2
## Collision radius in map pixels (kept small so corridors stay passable).
@export_range(1, 8) var body_radius: int = 2

var _image: Image
var _map: Sprite2D
var _walkable: BitMap
var _size: Vector2i


func _ready() -> void:
	_map = get_node(map_sprite_path) as Sprite2D
	_image = Image.new()
	var err := _image.load(map_image_path)
	if err != OK:
		push_error("WalkableMap: nie udało się wczytać mapy: %s" % map_image_path)
		return
	_image.convert(Image.FORMAT_RGBA8)
	_size = _image.get_size()
	_build_walkable_mask()


func _build_walkable_mask() -> void:
	var raw := BitMap.new()
	raw.create(_size)

	for y in range(_size.y):
		for x in range(_size.x):
			var color := _image.get_pixel(x, y)
			var brightness := (color.r + color.g + color.b) / 3.0
			if brightness >= brightness_threshold and color.a >= 0.5:
				raw.set_bitv(Vector2i(x, y), true)

	_walkable = BitMap.new()
	_walkable.create(_size)

	var expand := floor_expand
	for y in range(_size.y):
		for x in range(_size.x):
			var ok := false
			for oy in range(-expand, expand + 1):
				for ox in range(-expand, expand + 1):
					var nx := x + ox
					var ny := y + oy
					if nx < 0 or ny < 0 or nx >= _size.x or ny >= _size.y:
						continue
					if raw.get_bitv(Vector2i(nx, ny)):
						ok = true
						break
				if ok:
					break
			_walkable.set_bitv(Vector2i(x, y), ok)


func world_to_pixel(world_pos: Vector2) -> Vector2i:
	var local := _map.to_local(world_pos)
	return Vector2i(int(floor(local.x)), int(floor(local.y)))


func pixel_to_world(pixel: Vector2i) -> Vector2:
	return _map.to_global(Vector2(pixel) + Vector2(0.5, 0.5))


func is_pixel_walkable(pixel: Vector2i) -> bool:
	if _walkable == null:
		return false
	if pixel.x < 0 or pixel.y < 0 or pixel.x >= _size.x or pixel.y >= _size.y:
		return false
	return _walkable.get_bitv(pixel)


func can_stand_at(world_pos: Vector2) -> bool:
	var center := world_to_pixel(world_pos)
	var radius := body_radius
	# Sparse circle samples — lighter and less sticky than filling every pixel.
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var dx := x - center.x
			var dy := y - center.y
			if dx * dx + dy * dy > radius * radius:
				continue
			if not is_pixel_walkable(Vector2i(x, y)):
				return false
	return true


func estimate_wall_normal(world_pos: Vector2) -> Vector2:
	var center := world_to_pixel(world_pos)
	var gradient := Vector2.ZERO
	var step := maxi(body_radius, 2)

	for oy in range(-step, step + 1):
		for ox in range(-step, step + 1):
			if ox == 0 and oy == 0:
				continue
			if not is_pixel_walkable(Vector2i(center.x + ox, center.y + oy)):
				gradient += Vector2(ox, oy)

	if gradient == Vector2.ZERO:
		return Vector2.ZERO
	return gradient.normalized()


func find_spawn_pixel(clearance: int = 14) -> Vector2i:
	if _walkable == null:
		return Vector2i(-1, -1)

	var center := preferred_spawn
	if _has_clearance(center, clearance):
		return center

	var max_radius := mini(_size.x, _size.y) / 2
	for radius in range(2, max_radius, 2):
		for angle_step in range(0, 360, 8):
			var angle := deg_to_rad(float(angle_step))
			var point := Vector2i(
				center.x + int(cos(angle) * float(radius)),
				center.y + int(sin(angle) * float(radius))
			)
			if _has_clearance(point, clearance):
				return point

	return Vector2i(-1, -1)


func _has_clearance(center: Vector2i, clearance: int) -> bool:
	for y in range(center.y - clearance, center.y + clearance + 1):
		for x in range(center.x - clearance, center.x + clearance + 1):
			var dx := x - center.x
			var dy := y - center.y
			if dx * dx + dy * dy > clearance * clearance:
				continue
			if not is_pixel_walkable(Vector2i(x, y)):
				return false
	return true

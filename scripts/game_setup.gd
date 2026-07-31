extends Node2D

## Spawns the player on walkable cafeteria floor.

@onready var walkable: WalkableMap = $WalkableMap
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	await get_tree().process_frame
	_place_player()


func _place_player() -> void:
	var pixel := walkable.find_spawn_pixel(12)
	if pixel.x < 0:
		# Hard fallback: cafeteria floor on the Skeld map.
		pixel = Vector2i(300, 280)

	var spawn := walkable.pixel_to_world(pixel)
	player.global_position = spawn
	player.velocity = Vector2.ZERO
	camera.global_position = spawn

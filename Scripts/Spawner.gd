extends Area2D
class_name Spawner

const DIRECTION_VECTORS: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

@export var object_scene : PackedScene
@export var interval : Vector2
@export_enum("Up", "Down", "Left", "Right") var direction: int = 0

var spawn_timer : Timer


func _ready():
	spawn_item()


func get_direction_vector() -> Vector2:
	return DIRECTION_VECTORS[direction]


func spawn_item():
	if object_scene == null:
		return

	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start(randf_range(interval.x, interval.y))


func _on_spawn_timer_timeout():
	var spawned_item = object_scene.instantiate()
	add_child(spawned_item)
	spawned_item.global_position = _get_random_spawn_position()
	spawn_timer.start(randf_range(interval.x, interval.y))


func _get_random_spawn_position() -> Vector2:
	var collision_shape = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or not collision_shape.shape is RectangleShape2D:
		return global_position

	var rectangle = collision_shape.shape as RectangleShape2D
	var local_position = Vector2(
		randf_range(-rectangle.size.x / 2.0, rectangle.size.x / 2.0),
		randf_range(-rectangle.size.y / 2.0, rectangle.size.y / 2.0)
	)
	return collision_shape.to_global(local_position)

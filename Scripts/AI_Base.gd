extends Node2D


@export var min_max_speed := Vector2(40.0, 60.0)
@export var start_loc : Vector2 = Vector2(-100, 0)
@export var end_loc : Vector2 = Vector2(100, 0)
@export var choices : Array[AtlasTexture]
var body : CharacterBody2D
var nav : NavigationAgent2D
enum ESTATE {
	IDLE,
	WORKING,
	SLEEPING
}
var current_state : ESTATE = ESTATE.IDLE

func _ready():
	if len(choices) > 0:
		%Sprite2D.texture = choices.pick_random()

	body = find_child("CharacterBody2D")
	nav = find_child("NavigationAgent2D")
	nav.navigation_finished.connect(swap_loc)
	swap_loc()

func _physics_process(_delta):
	if body == null or nav == null:
		return

	if current_state != ESTATE.IDLE:
		return
		
	if not nav.is_navigation_finished():
		var next_point = nav.get_next_path_position()
		var dir = (next_point - global_position).normalized()
		var s = randf_range(min_max_speed.x, min_max_speed.y)
		global_position += dir * s * _delta

func swap_loc():
	await get_tree().create_timer(randf_range(0.2, 1.0)).timeout

	if nav.target_position == end_loc:
		nav.target_position = start_loc
	else:
		nav.target_position = end_loc
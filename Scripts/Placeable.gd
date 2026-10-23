extends Area2D
class_name Placeable

@warning_ignore_start("unused_parameter")

var has_been_placed := false
var is_held := false
var pickup_position : Vector2
var pickup_offset : Vector2
var can_be_replaced := true # TODO Make some items placeable only once
var try_rebake := true
var hovered := false
var can_interact := false

var hold_counter = 0.0
var hold_time = 0.5

#TODO: Ensure placeable does not overlap with other objects
#TODO: Add an Interface node, as a variable for swapping.

func _ready():
	set_process_input(false)
	input_event.connect(_on_input_event)
	mouse_entered.connect(hover_begin)
	mouse_exited.connect(hover_end)

func load_data(data_in : ItemData):
	pickup()

func _process(delta):
	if is_held:
		held()
	
	if !can_interact:
		return
	elif can_interact and Input.is_action_pressed("select"):
		hold_counter += delta
	else:
		hold_counter = 0.0

	if !is_held and can_interact and hold_counter >= hold_time:
		pickup()


func _input(event):
	if event.is_action_released("select"):
		if is_held:
			release_hold()
			return
		elif hold_counter < hold_time and can_interact:
			single_click()
			return

	if event.is_action_pressed("clear") and is_held:
		release_hold()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("select"):
		set_process_input(true)
		can_interact = true


func pickup():
	set_process_input(true)
	is_held = true
	Calendar.game_pause.emit()
	pickup_position = position
	pickup_offset = pickup_position - get_global_mouse_position()
	move_to_front()

func held():
	#While holding, we move it to the mouse position, snapping to grid size
	var mouse_pos = get_global_mouse_position() + pickup_offset
	position = snap_pos_to_grid(mouse_pos)

func release_hold():
	hold_counter = 0.0
	is_held = false

	if has_overlapping_areas():
		clear_hold()
		return

	post_hold()

func clear_hold():
	is_held = false
	position = pickup_position
	post_hold()

func post_hold():
	set_process_input(false)
	can_interact = false

	if not has_been_placed:
		first_placement()
		has_been_placed = true
		
	Calendar.game_play.emit()

	if try_rebake:
		Events.rebake_navmesh.emit()


func first_placement():
	pass

func single_click():
	set_process_input(false)
	pass

func hover_begin():
	if Calendar.is_paused:
		return
	hovered = true

func hover_end():
	can_interact = false
	if Calendar.is_paused:
		return
	hovered = false

func snap_pos_to_grid(position_in):
	var pos_out: Vector2
	pos_out.x = floor(position_in.x/Globals.SNAP_SIZE) * Globals.SNAP_SIZE
	pos_out.y = floor(position_in.y/Globals.SNAP_SIZE) * Globals.SNAP_SIZE
	return pos_out

func display_overlaps():
	# TODO: Signal to player that they cannot release placeable due to overlap
	pass

func remove():
	var nav_ob = find_child("NavigationObstacle2D") as NavigationObstacle2D
	if nav_ob != null:
		nav_ob.affect_navigation_mesh = false
	
	Events.rebake_navmesh.emit()
	queue_free()
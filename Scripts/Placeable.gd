extends Node2D
class_name Placeable

@onready var area : Area2D = self.find_child("Area2D")

var is_held := false
var held_offset := Vector2.ZERO
var can_release_here := true
var pickup_position : Vector2

var interface : Node

#TODO: Ensure placeable does not overlap with other objects
#TODO: Add an Interface node, as a variable for swapping.

func _ready():
	if area != null:
		area.input_event.connect(_on_input_event)
		area.mouse_entered.connect(hover_begin)
		area.mouse_exited.connect(hover_end)
	else:
		printerr("This placeable does not have an Area2D!")

func _process(_delta):
	if not is_held:
		return
	held()

func held():
	#While holding, we move it to the mouse position, snapping to grid size
	Calendar.game_pause.emit()
	var mouse_pos = get_global_mouse_position() + held_offset
	position = snap_pos_to_grid(mouse_pos)
	#If area overlaps any other area, do not allow release
	if area.has_overlapping_areas():
		can_release_here = false
	else:
		can_release_here = true
	
func release_hold(keep_position : bool):
	Calendar.game_play.emit()
	if keep_position:
		is_held = false
	else:
		if is_held:
			position = pickup_position
		is_held = false
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("select"):
		if area.has_overlapping_areas():
			return
		is_held = true
		held_offset = position - get_global_mouse_position()
		pickup_position = position
		move_to_front()
	elif event.is_action_released("select") and can_release_here:
		release_hold(true)
	elif event.is_action_pressed("clear"):
		release_hold(false)

func hover_begin():
	if Calendar.is_paused:
		return

func hover_end():
	if Calendar.is_paused:
		return

func snap_pos_to_grid(position_in):
	var pos_out: Vector2
	pos_out.x = floor(position_in.x/Globals.SNAP_SIZE) * Globals.SNAP_SIZE
	pos_out.y = floor(position_in.y/Globals.SNAP_SIZE) * Globals.SNAP_SIZE
	return pos_out

func display_overlaps():
	# TODO: Signal to player that they cannot releasse placeable due to overlap
	pass
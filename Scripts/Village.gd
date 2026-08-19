extends Node2D

@onready var area : Area2D = self.find_child("Area2D")

@export var pop_up_data : PopUpData

func _ready():
	if area != null:
		area.input_event.connect(_on_input_event)
		area.mouse_entered.connect(hover_begin)
		area.mouse_exited.connect(hover_end)
	else:
		printerr("This placeable does not have an Area2D!")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("select"):
		if not area.has_overlapping_areas():
			Events.request_pop_up.emit(pop_up_data, self)

func hover_begin():
	if Calendar.is_paused:
		return
	%Outline.visible = true

func hover_end():
	if Calendar.is_paused:
		return
	%Outline.visible = false

func get_bounds() -> Vector2:
	return area.find_child("CollisionShape2D").shape.size

func get_random_point_in_bounds() -> Vector2:
	var half_bounds = Vector2(get_bounds().x/2, get_bounds().y/2)
	return Vector2(
		randf_range(0 - half_bounds.x, half_bounds.x) + position.x, 
		randf_range(0 - half_bounds.y, half_bounds.y) + position.y)
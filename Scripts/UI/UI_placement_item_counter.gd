extends Control

@export var item_data : ItemData
var count : int = 0


func _ready():
	if item_data == null:
		return
	Inventory.update_ui.connect(_on_update_ui)
	%Button.button_down.connect(_on_down)

func set_empty():
	if count <= 0:
		modulate = Color(1.0, 1.0, 1.0, 0.5)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_update_ui():
	count = int(Inventory.get_item_quantity(item_data))
	%Label_Count.text = str(count)
	%TextureRect.texture = item_data.icon
	set_empty()

func _on_down():
	if count <= 0:
		return
	Inventory.request_spawn_item.emit(item_data)
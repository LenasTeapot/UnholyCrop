extends Control

@export var plot_data : ItemData_Plot
var count : int = 0


func _ready():
	Inventory.update_ui.connect(_on_update_ui)
	%Button.pressed.connect(_on_pressed)

func set_empty():
	if count <= 0:
		modulate = Color(1.0, 1.0, 1.0, 0.5)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_update_ui():
	count = int(Inventory.get_item_quantity(plot_data))
	%Label_Count.text = str(count)
	%Label_PlotSize.text = str(plot_data.grid_size, "x", plot_data.grid_size)
	%TextureRect.texture = plot_data.icon
	set_empty()

func _on_pressed():
	if count <= 0:
		return
	Inventory.request_spawn_item.emit(plot_data)

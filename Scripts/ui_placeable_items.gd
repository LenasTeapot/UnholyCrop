extends Control

@export_file_path var item_icon_path : String

func _ready():
	if item_icon_path == null:
		printerr("No scene path given!!")
		return

	for item : ItemData in Globals.ITEMS:
		var new_icon = load(item_icon_path).instantiate()
		%Container.add_child(new_icon)
		new_icon.item_data = item


extends Action
class_name Action_ConfirmCrop

@export var new_crop : ItemData_Crop

func do_action(node):
	if node is Placeable_Plot:
		node.change_crop(new_crop)

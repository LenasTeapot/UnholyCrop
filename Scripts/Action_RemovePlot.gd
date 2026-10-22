extends Action
class_name Action_RemovePlot

func do_action(node):
	if node is Placeable:
		node.remove()

extends Action
class_name Action_AssignWorker

@export var amount : int = 0

func do_action(node):
	if node is Placeable_Plot:
		node.add_worker(amount)

extends CanvasLayer

var pop_up : Node
var pop_up_owner : Node

var pop_up_queue = {}
# TODO : Create Pop Up Data class
# Scene path, pause bool
# Sub class for dialogue from village or diety

func _ready():
	Events.connect("request_pop_up", _on_request_pop_up)
	Events.connect("close_pop_up", _on_close_pop_up)
	Events.connect("pop_up_cancelled", _on_pop_up_cancelled)
	Events.connect("pop_up_confirmed", _on_pop_up_confirmed)
	Events.connect("pop_up_action", _on_pop_up_action)

func _on_request_pop_up(_pop_up_data : PopUpData, _owning_node : Node):
	if pop_up != null:
		pop_up_queue[_pop_up_data] = _owning_node
		return

	if _pop_up_data.pause_game:
		Calendar.emit_signal("game_pause")

	pop_up = load(_pop_up_data.scene_path).instantiate()
	pop_up_owner = _owning_node
	add_child(pop_up)

	if pop_up.has_method("load_data"):
		pop_up.load_data(_pop_up_data)

func _on_close_pop_up():
	if pop_up == null:
		return

	pop_up.queue_free()
	pop_up = null
	pop_up_owner = null

	if len(pop_up_queue) != 0:
		var next_pop_up_data = pop_up_queue.keys()[0]
		var next_pop_up_owner = pop_up_queue[next_pop_up_data]
		pop_up_queue.erase(next_pop_up_data)
		_on_request_pop_up(next_pop_up_data, next_pop_up_owner)
	else:
		Calendar.emit_signal("game_play")

func _on_pop_up_cancelled():
	if pop_up == null:
		return
	else:
		_on_close_pop_up()

func _on_pop_up_confirmed():
	if pop_up == null:
		return
	else:
		_on_close_pop_up()

func _on_pop_up_action(action):
	if pop_up == null:
		return
	else:
		action.do_action(pop_up_owner)
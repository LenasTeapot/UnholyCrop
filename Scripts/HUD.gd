extends CanvasLayer

var pop_up : Node
var pop_up_owner : Node
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
		return
	pop_up = load(_pop_up_data.scene_path).instantiate()
	pop_up_owner = _owning_node
	add_child(pop_up)
	if _pop_up_data.pause_game:
		Calendar.emit_signal("game_pause")

func _on_close_pop_up():
	if pop_up == null:
		return
	Calendar.emit_signal("game_play")
	pop_up.queue_free()
	pop_up = null
	pop_up_owner = null
	
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
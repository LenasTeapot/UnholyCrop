extends Panel

var pause_length := 2.0

func _ready():
	%Label.text = Calendar.get_current_season().name
	var timer = new_timer(pause_length)
	timer.timeout.connect(end_pause)

func end_pause():
	Events.emit_signal("close_pop_up")

func new_timer(duration):
	var timer = Timer.new()
	timer.wait_time = duration
	timer.ignore_time_scale = true
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	return timer
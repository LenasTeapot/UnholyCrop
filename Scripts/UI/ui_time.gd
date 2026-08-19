extends Control

func _ready():
	%Increase_Button.pressed.connect(func(): Calendar.increase_timescale())
	%Decrease_Button.pressed.connect(func(): Calendar.decrease_timescale())
	%Play_Button.pressed.connect(func(): Calendar.game_play.emit())
	%Pause_Button.pressed.connect(func(): Calendar.game_pause.emit())
	Calendar.timescale_changed.connect(func(): %Label.text = str(Calendar.current_timescale))
	

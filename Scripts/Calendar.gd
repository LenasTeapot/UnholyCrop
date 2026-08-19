@tool
extends Node

### TODO: Seasons (P0) Done.
### TODO: Day/Night (P1)
### TODO: Speed and Slow (P2)

### Settings
var day_length := 3.0

var day_timer : Timer
var current_timescale := 1
var is_paused := true

@warning_ignore_start("unused_signal")
signal game_pause
signal game_play
signal day_end
signal season_end
signal timescale_changed

var Seasons = []
var current_day : int = 1
var current_season : int = 0
var current_year : int = 1
var year_length : int = 0

func _ready():
	# Signal connect
	game_pause.connect(_on_game_pause)
	game_play.connect(_on_game_play)
	# Timer set up
	day_timer = new_timer(day_length)
	day_timer.timeout.connect(_on_day_end)
	
	set_timescale()
	
func calc_year_length():
	var y = 0
	for i in len(Seasons):
		y += Seasons[0].length
	return y

func calculate_season():
	if current_day > year_length:
		current_season = 0
		current_day = 1
		current_year += 1
		change_seaon()
		return
	
	var day_sum : int = 0
	for i in len(Seasons):
		day_sum += Seasons[0].length
		if current_day <= day_sum:
			if current_season != i:
				current_season = i
				change_seaon()
			else:
				current_season = i
			return
			
func get_current_season():
	return Seasons[current_season]
	
func _on_day_end():
	print ("Day ", current_day, " is over.")
	day_end.emit(current_day)
	current_day += 1
	calculate_season()
	
func change_seaon():
	print("The current season is ", get_current_season().name, " of year ", current_year)
	season_end.emit(get_current_season())
	
func _on_game_pause():
	#print("Pause game")
	is_paused = true
	set_timescale()
	
func _on_game_play():
	#print("Play game")
	is_paused = false
	set_timescale()

func set_timescale():
	if is_paused:
		Engine.time_scale = 0
	else:
		Engine.time_scale = current_timescale
		
	timescale_changed.emit()

func increase_timescale():
	current_timescale = clamp(current_timescale + 1, 0, 10)
	set_timescale()

func decrease_timescale():
	current_timescale = clamp(current_timescale -  1, 0, 10)
	set_timescale()

func new_timer(duration):
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.autostart = true
	timer.wait_time = duration
	return timer

func load_game(_seasons_in):
	Seasons = _seasons_in
	year_length = calc_year_length()
	change_seaon()
	
	day_timer.start()
	
func save_game():
	#PLACEHOLDER
	pass

extends Label

#TODO : When game selection is implemented this can be simplified to await a game config signal

var initial_text := ""

func _ready():
	initial_text = text
	Quests.loaded.connect(loaded)
	Calendar.loaded.connect(on_day_end)
	Calendar.day_end.connect(on_day_end)

func loaded():
	initial_text = Globals.rename_globals(text)
	on_day_end(null)

func on_day_end(_current_day):
	if Quests == null:
		return
	text = initial_text.format({"countdown": Quests.get_end_quest().timeline})
	
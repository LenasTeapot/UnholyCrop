extends Node2D

### Main Global systems needed here or maybe as autoloads?
	### Inventory (needs to read output from plots)
	### Quest Manager (for the final objective as well as pop up events)
	### NPC Manager? (Reads the day and gives them tasks)
	### Haunter (for special moments and FX)
	### Serialization? Serializer? 


@export_file_path var npc_path : String = "res://Scenes/NPC_Base.tscn"

@export_category("Settings")
@export var _seasons : Array[Season]
@export var starting_villager_count : int


func _ready():
	# TODO : Set up some settings, remeber any changes etc
	var screen_size = DisplayServer.screen_get_size()
	if screen_size.x <= DisplayServer.window_get_size().x:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


	Events.add_villager.connect(_on_add_villager)
	Events.add_plot.connect(on_add_item)
	Calendar.load_game(_seasons)
	Inventory.load_game(starting_villager_count)
	Quests.load_game()


func _physics_process(_delta: float):
	if Input.is_action_just_pressed("close"):
		_exit_game()

func _new_game():
	pass
	
func _save_game():
	pass

func _load_game():
	pass
	
func _exit_game():
	#TODO : Prompt save?
	get_tree().quit()

func _on_add_villager():
	var villager = load(npc_path).instantiate()
	%NPCs.add_child(villager)
	villager.position = %Village.get_random_point_in_bounds()


### Depreciate!
func _on_add_plot(plot_data):
	var plot = load(plot_data.scene_path).instantiate()
	%NavigationRegion2D.add_child(plot)
	plot.plot_data = plot_data
	plot.global_position = get_global_mouse_position()
	plot.is_held = true # BAD

func on_add_item(item_data : ItemData):
	if item_data == null:
		return
	var item = load(item_data.scene_path).instantiate()
	%NavigationRegion2D.add_child(item)
	item.global_position = get_global_mouse_position()
	if item.has_method("load_data"):
		item.load_data(item_data)


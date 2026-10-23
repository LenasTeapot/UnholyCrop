extends Node

@warning_ignore_start("integer_division")

# SETTINGS
var START_VILLAGER_COUNT : int = 4

# Calendar Settings
var SEASONS : Array[Season] = [
	preload("res://Resources/Season_Spring.tres"), 
	preload("res://Resources/Season_Summer.tres"), 
	preload("res://Resources/Season_Autumn.tres"), 
	preload("res://Resources/Season_Winter.tres")
	]
var DAY_LENGTH := 4.0
var SEASON_LENGTH := 24

# Quest Settings
var END_QUEST_LENGTH_YEARS := 2
var MIN_DAYS_TO_QUEST := SEASON_LENGTH/4
var MAX_DAYS_TO_QUEST := SEASON_LENGTH/3
var DIFFICULTY_DIV := 3
var END_QUEST_MIN_FEAST_CROP := 10 * 8 # Move multiplier?
var END_QUEST_MAX_FEAST_CROP := 10 * 12

# Grid Settings
const SNAP_SIZE := 8.0
const GRID_SIZE := 16.0

# Item Settings
const CROP_TYPES : Array[ItemData_Crop] = [
	preload("res://Resources/Item_Tomato.tres"),
	preload("res://Resources/Item_Carrot.tres"),
	preload("res://Resources/Item_Corn.tres"),
	preload("res://Resources/Item_Turnip.tres"),
	preload("res://Resources/Item_Mushroom.tres")
]

const VILLAGER : ItemData = preload("res://Resources/Item_Villager.tres")

# Items given as rewards etc
const ITEMS : Array[ItemData] = [
	preload("res://Resources/Item_Plot_3.tres"),
	preload("res://Resources/Item_Plot_5.tres"),
	preload("res://Resources/Item_Fence.tres"),
	preload("res://Resources/Item_Scarecrow.tres")
]

# Diety Settings

const GOD_OPTIONS = [
	"res://Resources/GodData_Corn.tres",
	"res://Resources/GodData_Mushroom.tres",
	"res://Resources/GodData_Rot.tres"
]

const PLAYER_NAME_OPTIONS = ["Mayor", "Regent", "Chief"]

const PRIEST_TITLE_OPTIONS = ["high priest", "holy seer", "speaker"]


# Runtime
var current_god : GodData

var global_names = {
	"PLAYER_NAME" : PLAYER_NAME_OPTIONS.pick_random(),
	"PRIEST_TITLE" : PRIEST_TITLE_OPTIONS.pick_random(),
	"GOD_NAME" : ""
}

func rename_globals(string_in : String) -> String:
	var string_out = string_in
	return string_out.format(global_names)

func _ready():
	current_god = load(GOD_OPTIONS.pick_random())
	global_names["GOD_NAME"] = current_god.god_name

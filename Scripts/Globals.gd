extends Node

const SNAP_SIZE := 8.0
const GRID_SIZE := 16.0

const CROP_TYPES : Array[ItemData_Crop] = [
    preload("res://Resources/Item_Tomato.tres"),
    preload("res://Resources/Item_Carrot.tres"),
    preload("res://Resources/Item_Corn.tres"),
    preload("res://Resources/Item_Turnip.tres"),
    preload("res://Resources/Item_Mushroom.tres")
]

const VILLAGER : ItemData = preload("res://Resources/Item_Villager.tres")

const PLOTS : Array[ItemData] = [
    preload("res://Resources/Item_Plot_2.tres"),
    preload("res://Resources/Item_Plot_3.tres"),
    preload("res://Resources/Item_Plot_4.tres"),
    preload("res://Resources/Item_Plot_5.tres")
]

const GOD_NAME_OPTIONS = ["Mushroom", "Corn", "Rot"]

const PLAYER_NAME_OPTIONS = ["Mayor", "Regent", "Chief"]

const PRIEST_TITLE_OPTIONS = ["high priest", "holy seer", "speaker"]

var global_names = {
    "PLAYER_NAME" : PLAYER_NAME_OPTIONS.pick_random(),
    "PRIEST_TITLE" : PRIEST_TITLE_OPTIONS.pick_random(),
    "GOD_NAME" : GOD_NAME_OPTIONS.pick_random() 
}

func rename_globals(string_in : String) -> String:
    var string_out = string_in
    for k in global_names.keys():
        string_out = string_out.replace(k, global_names[k])
    return string_out


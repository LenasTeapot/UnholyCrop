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
@tool
extends ItemData
class_name ItemData_Crop

@export_category("Crop Settings")
@export var growth_time : int
@export var growth_modifiers : Dictionary[Season, float]   # {Season : float}
@export var growth_icons : Array[AtlasTexture]

func get_sprite_by_progress(_current_progress : float) -> AtlasTexture:
	var period = growth_time/float(len(growth_icons))
	var i = (_current_progress/period) - 1
	return growth_icons[clampf(int(i), 0, len(growth_icons) - 1)]

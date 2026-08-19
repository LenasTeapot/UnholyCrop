extends Node2D

func _ready():
	Calendar.season_end.connect(_on_season_end)
	
func _on_season_end(season_in : Season):
	var mat = material as ShaderMaterial
	
	var category = ""
	for property in season_in.get_script().get_script_property_list():
		if property.usage == PROPERTY_USAGE_CATEGORY:
			category = property.name
		elif category == "ShaderParameter" && property.usage == 4102: 
			mat.set_shader_parameter(property.name, season_in.get(property.name))

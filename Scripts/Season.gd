extends Resource
class_name Season

@export_category("General")
@export var name : String
@export var length : int

@export_category("ShaderParameter")
@export var hue_shift : float = 0.0
@export var saturation_mult : float = 1.0
@export var value_mult : float = 1.0
@export var brightness_add : float = 0.0
@export var contrast_mult : float = 1.0
@export var value_invert : bool = false

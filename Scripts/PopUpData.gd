extends Resource
class_name PopUpData

@export_file var scene_path : String
@export var pause_game : bool
@export_category("Configuration")
@export var title : String
@export_multiline var description : String
@export var use_description : bool = true
@export var use_portrait : bool = false
@export var use_options : bool = false
@export var option_data : Array[PopUpOptionData]
@export var use_information : bool = false #TODO :  How to pass information? Action class?

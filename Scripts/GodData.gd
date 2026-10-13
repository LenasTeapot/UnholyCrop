extends Resource
class_name GodData

@export_category("Presets")
@export var god_name : String
@export var icon : Texture2D

# TODO : 
# End scene path, pass fail
# Extra rewards or unlockable crops 
# Random Events
# Events for low standing
# Events for high standing

# Do I need any runtime var saved here, or can that live in Quests only?
#@export_category("Runtime")
#@export var current_standing : int
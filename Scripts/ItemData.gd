extends Resource
class_name ItemData

@export_category("Display Settings")
@export var item_name : String
@export_multiline var description : String
@export var icon : Texture2D
@export_category("Reward Settings")
@export var reward_weight : int = 1

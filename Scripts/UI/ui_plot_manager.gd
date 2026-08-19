extends Node

var plot_node : Placeable_Plot
var current_crop_type : int

func _ready():
	plot_node = get_parent().pop_up_owner
	current_crop_type = Globals.CROP_TYPES.find(plot_node.item)
	%Left_Crop_Button.pressed.connect(func(): scroll_icons(-1))
	%Right_Crop_Button.pressed.connect(func(): scroll_icons(1))
	%Confirm_Button.action.new_crop = Globals.CROP_TYPES[current_crop_type]
	_update()

func _update():
	%Worker_Amount.text = str(plot_node.workers)
	%Crop_Icon.set_texture(Globals.CROP_TYPES[current_crop_type].icon)

func _process(_delta):
	if Input.is_action_just_released("select"):
		_update()

func scroll_icons(dir : int):
	current_crop_type += dir

	if current_crop_type < 0:
		current_crop_type = len(Globals.CROP_TYPES) -1

	elif current_crop_type == len(Globals.CROP_TYPES):
		current_crop_type = 0

	%Confirm_Button.action.new_crop = Globals.CROP_TYPES[current_crop_type]

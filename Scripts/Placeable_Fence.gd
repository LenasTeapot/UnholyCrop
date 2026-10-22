extends Placeable
class_name Placeable_Fence

func single_click():
	super()
	if rotation_degrees == 90:
		rotation_degrees = 0
	else:
		rotation_degrees = 90

func pickup():
	super()
	%Outline.visible = true

func post_hold():
	super()
	%Outline.visible = false

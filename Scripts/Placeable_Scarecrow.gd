extends Placeable

func _ready():
	super()
	try_rebake = false

func pickup():
	super()
	%Outline.visible = true

func post_hold():
	super()
	%Outline.visible = false

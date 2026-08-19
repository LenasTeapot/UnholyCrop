extends BaseButton

@export var signal_name : String
@export var action : Action

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	if action != null:
		Events.emit_signal("pop_up_action", action)
	if signal_name != null and signal_name != "":
		Events.emit_signal(signal_name)
	

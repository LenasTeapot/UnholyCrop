extends Button

@export var pop_up_data : PopUpData

func _ready():
    pressed.connect(_on_pressed)

func _on_pressed():
    print(owner)
    if Calendar.is_paused:
        return
    if pop_up_data != null:
        Events.request_pop_up.emit(pop_up_data, owner)
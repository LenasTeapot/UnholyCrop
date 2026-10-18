extends ProductionModifier
class_name Modifier_Pest

var sprite_id := 0
# Have it store which sprite it has taken?

@warning_ignore_start("unused_parameter")

func _init():
    temporary = true

func run(grid_size : int, current_value : int):
    return current_value - 1
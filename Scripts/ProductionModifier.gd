extends Resource
class_name ProductionModifier

var temporary := false

@warning_ignore("unused_parameter")

func run(grid_size : int, current_value : int):
    return current_value
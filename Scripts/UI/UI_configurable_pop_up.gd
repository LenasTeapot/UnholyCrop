extends Panel

func load_data(data : PopUpData):
	%Title.text = data.title
	%Description.visible = not data.description == ""
	%Description.text = Globals.rename_globals(data.description)
	%Portrait_Container.visible = data.use_portrait

	var has_options = len(data.option_data) > 0
	%Close_Button.visible = not has_options
	%Options_Container.visible = has_options
	if has_options:
		display_options(data)

	var has_information = len(data.information_data) > 0
	if has_information:
		display_information(data)
	

func display_options(data):
	for o in data.option_data:
		var new_option = load("res://Scenes/ui_pop_up_option.tscn").instantiate()
		%Options_Container.add_child(new_option)
		var button = new_option.find_child("Button")
		button.text = o.button_label
		button.pressed.connect(func(): Events.emit_signal(o.event_signal))

func display_information(data):
	for i in data.information_data:
		var new_info = load("res://Scenes/ui_pop_up_information.tscn").instantiate()
		%Information_Container.add_child(new_info)
		new_info.load_information(i)

extends Panel

func load_data(data : PopUpData):
	%Title.text = data.title
	%Close_Button.visible = not data.use_options
	%Options_Container.visible = data.use_options
	for o in data.option_data:
		var new_option = load("res://Scenes/ui_pop_up_option.tscn").instantiate()
		%Options_Container.add_child(new_option)
		var button = new_option.find_child("Button")
		button.text = o.button_label
		button.pressed.connect(func(): Events.emit_signal(o.event_signal))

	%Description.text = Globals.rename_globals(data.description)
	%Portrait_Container.visible = data.use_portrait
	%Information_1_Label.visible = data.use_information    
	%Information_2_Label.visible = data.use_information

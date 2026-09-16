extends HBoxContainer

var quest_item = preload("res://Scenes/ui_quest_item.tscn")

func load_information(data : PopUpInformationData):
	%Information_Label.text = data.label

	match data.type:
		PopUpInformationData.INFO_TYPE.CURRENT_QUEST_REQUIREMENTS:
			var quest_data = Quests.get_current_quest()
			display_items(quest_data.requirements)
		PopUpInformationData.INFO_TYPE.CURRENT_QUEST_REWARDS:
			var quest_data = Quests.get_current_quest()
			display_items(quest_data.rewards)
		PopUpInformationData.INFO_TYPE.END_QUEST:
			var quest_data = Quests.get_end_quest()
			display_items(quest_data.requirements)

func display_items(items : Dictionary[ItemData, float]):
	for i in items.keys():
		var new_item = quest_item.instantiate()
		add_child(new_item)
		new_item.load_item(i, items[i])

extends Control

var ui_item = preload("res://Scenes/ui_quest_item.tscn")

func _ready():
	var quest_data : Quests.QuestData = Quests.get_current_quest()
	for i in quest_data.requirements:
		var new_ui_item = ui_item.instantiate()
		%ItemContainer.add_child(new_ui_item)
		new_ui_item.load_item(i, quest_data.requirements[i])

	for r in quest_data.rewards:
		var new_reward = ui_item.instantiate()
		%RewardContainer.add_child(new_reward)
		new_reward.load_item(r, quest_data.rewards[r])

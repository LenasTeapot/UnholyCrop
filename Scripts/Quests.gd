@tool
extends Node

var end_quest : QuestData

var current_active_quest : QuestData
var completed_quests : Array[QuestData]

var quest_complete : bool = false

var pop_up_data : PopUpData = preload("res://Resources/PopUpData_Quest.tres")
var initial_pop_up : PopUpData = preload("res://Resources/PopUpInitialQuest.tres")

signal quest_updated

func load_game():
	if end_quest == null:
		end_quest = QuestData.new()
		end_quest.make_random_end_quest()

	if current_active_quest == null:
		new_quest()

	Inventory.update_ui.connect(_on_inventory_updated)
	quest_updated.emit()
	Events.accept_completed_quest.connect(on_accept_completed_quest)
	Events.decline_completed_quest.connect(on_decline_completed_quest)

	Events.request_pop_up.emit(initial_pop_up, self)

func new_quest():
	current_active_quest = QuestData.new()
	current_active_quest.make_random(len(completed_quests))
	current_active_quest.print_quest()
	quest_complete = false

func _on_inventory_updated():
	if quest_complete:
		return

	if end_quest.check_quest_complete():
		print("END QUEST COMPLETE")
	elif current_active_quest != null:
		if current_active_quest.check_quest_complete():	
			quest_complete = true
			print("This quest is complete!")
			complete_quest()

func complete_quest():
	completed_quests.append(current_active_quest)
	Events.request_pop_up.emit(pop_up_data, self)

# TODO : hook quest options to pop up
func on_accept_completed_quest():
	for item in current_active_quest.requirements:
		Inventory.request_remove_item.emit(item, current_active_quest.requirements[item], true)

	for reward in current_active_quest.rewards:
		Inventory.request_add_item.emit(reward, current_active_quest.rewards[reward], true)


	current_active_quest = null
	Events.pop_up_confirmed.emit()
	new_quest()
	quest_updated.emit()

func on_decline_completed_quest():
	#TODO : Make a declined pop up to follow
	Events.pop_up_confirmed.emit()
	new_quest()
	quest_updated.emit()

func get_current_quest() -> QuestData:
	return current_active_quest

func get_end_quest() -> QuestData:
	return end_quest


class QuestData:
	var requirements : Dictionary[ItemData, float] # Crops
	var rewards : Dictionary[ItemData, int] # Plots and Workers (TODO : Should there be a choice of two different ones?)
	var timeline : int # In days? Or by a specific day of a season?

	var quest_name : String
	var quest_description : String

	func make_random(difficulty):
		# TODO: Create a difficulty scale for both requirements and rewards
		# Requirements
		var crops = Globals.CROP_TYPES.duplicate()
		for i in randi_range(1, 2):
			var x = crops.pick_random()
			requirements[x] = randi_range(1, 3) * (6 * (difficulty + 1))
			crops.erase(x)

		# Rewards
		var reward_score = 0
		if [true, false].pick_random():
			rewards[Globals.VILLAGER] = randi_range(1, 2)
			reward_score += 1
		var p = Globals.PLOTS.pick_random()
		rewards[p] = 2 - reward_score

		# Timeline
		timeline = randi_range(1, 4) * 8

		quest_name = str("General Quest : ", difficulty)

	func make_random_end_quest():
		var crops = Globals.CROP_TYPES
		for i in len(crops):
			requirements[crops[i]] = randi_range(10, 20) * 12.0

		timeline = Calendar.calc_year_length() * randi_range(2, 4)

		quest_name = "End Quest"

	func check_quest_complete():
		for r in requirements.keys():
			if Inventory.get_item_quantity(r) >= requirements[r]:
				return true
			else:
				return false

	func print_quest():
		var s = str("Quest: ")
		for i in requirements:
			s += str(i.item_name, " : ", requirements[i], "  ")
		s += "Reward: "
		for r in rewards:
			s += str(r.item_name, " : ", rewards[r], "  ")
		print(s)

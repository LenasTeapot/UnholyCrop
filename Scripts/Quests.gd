@tool
extends Node


### TODO: Change the small quest to trigger on a timer, request what is known to be in the inventory. 

@warning_ignore("unused_signal")
signal loaded

var end_quest : QuestData

var difficulty_increment = 4

var current_active_quest : QuestData
var completed_quests : Array[QuestData]

var pop_up_data : PopUpData = preload("res://Resources/PopUpData_Quest.tres")
var initial_pop_up : PopUpData = preload("res://Resources/PopUpInitialQuest.tres")

signal quest_updated

func load_game():
	if end_quest == null:
		end_quest = QuestData.new()
		end_quest.make_random_end_quest()

	if current_active_quest == null:
		new_quest()

	quest_updated.emit()

	Calendar.day_end.connect(on_day_end)
	Events.accept_completed_quest.connect(on_accept_completed_quest)
	Events.decline_completed_quest.connect(on_decline_completed_quest)

	Events.request_pop_up.emit(initial_pop_up, self)

	loaded.emit()

func on_day_end(_current_day):
	if current_active_quest.timeline == 0:
		current_active_quest.set_quest_requirements()
		complete_quest()
	
	if end_quest.timeline == 0:
		print("END QUEST COMPLETE")

func new_quest():
	current_active_quest = QuestData.new()
	current_active_quest.make_random(len(completed_quests))
	current_active_quest.print_quest()

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
	var requirements : Dictionary[ItemData, float] # Crops0    
	var rewards : Dictionary[ItemData, float] # Plots and Workers (TODO : Should there be a choice of two different ones?)
	var timeline : int # In days? Or by a specific day of a season?
	var difficulty : int
	var quest_name : String
	var quest_description : String

	func _init():
		Calendar.day_end.connect(_on_day_end)

	func _on_day_end(_current_day):
		timeline -= 1

	func make_random(_difficulty):
		# TODO: Create a difficulty scale for both requirements and rewards
		# Requirements
		difficulty = _difficulty 
		set_quest_requirements()

		# Rewards
		set_quest_rewards()

		# Timeline
		timeline = randi_range(3, 4) * 4

		quest_name = str("General Quest : ", difficulty)

	func set_quest_rewards():
		var reward_score = -1
		while reward_score < floor(difficulty/4):
			if [true, false].pick_random():
				var v = Globals.VILLAGER
				if rewards.has(v):
					rewards[v] = rewards[v] + 1
				else:
					rewards[v] = 1
				reward_score += 1

			#TODO : Rate plots by grid size and grant quantity based on that
			var p = Globals.PLOTS.pick_random()
			rewards[p] = 1
			reward_score += 1

	func set_quest_requirements():
		var crops = []

		#Erase all crops from pool with 0 inventory
		for crop in Globals.CROP_TYPES:
			var limit = Inventory.get_item_quantity(crop)
			if limit > 0:
				crops.append(crop)

		if len(crops) == 0:
			return

		var d = -1
		while d < floor(difficulty/4):
			var c = crops.pick_random()
			var limit = Inventory.get_item_quantity(c)
			var amount = randi_range(ceil(limit/6), ceil(limit/4))
			if requirements.has(c):
				requirements[c] = min(requirements[c] + amount, limit/2)
			else:
				requirements[c] = amount
			d += 1

	func make_random_end_quest():
		var crops = Globals.CROP_TYPES
		for i in len(crops):
			requirements[crops[i]] = randi_range(10, 20) * 12.0

		timeline = Calendar.calc_year_length() * randi_range(2, 4) 
		#TODO : Use a difficulty factor select number of years required

		quest_name = "End Quest"

	func check_quest_complete():
		for r in requirements.keys():
			if Inventory.get_item_quantity(r) >= requirements[r]:
				return true
			else:
				return false

	func print_quest():
		var s = str("Quest: ")
		s += str(quest_name, " ")
		for i in requirements:
			s += str(i.item_name, " : ", requirements[i], "  ")
		s += "Reward: "
		for r in rewards:
			s += str(r.item_name, " : ", rewards[r], "  ")
		s += str("Timeline: ", timeline)
		
		print(s)

@tool
extends Node

const DIFFICULTY_DIV = 3 # TODO: Make tunable from global settings? 
var difficulty_increment = 4

@warning_ignore("unused_signal")
signal loaded

# End Quest
var end_quest : QuestData

# Small Quests
var current_active_quest : QuestData
var completed_quests : Array[QuestData]
signal quest_updated

# Pop Ups
var pop_up_data : PopUpData = preload("res://Resources/PopUpData_Quest.tres")
var initial_pop_up : PopUpData = preload("res://Resources/PopUpInitialQuest.tres")
var end_pop_up : PopUpData = preload("res://Resources/PopUpData_EndQuest.tres")

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
		current_active_quest.set_quest_rewards()
		current_active_quest.print_quest()
		complete_quest()
	
	if end_quest.timeline == 0:
		Events.request_pop_up.emit(end_pop_up, self)

func new_quest():
	current_active_quest = QuestData.new()
	current_active_quest.make_random(len(completed_quests))

func complete_quest():
	if len(current_active_quest.requirements) == 0:
		new_quest()
		return
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
		difficulty = floor(_difficulty/DIFFICULTY_DIV) + 1
		timeline = randi_range(3, 4) * 4
		quest_name = str("General Quest ", difficulty)

	func set_quest_rewards():
		var possible_rewards = Globals.PLOTS.duplicate()
		possible_rewards.append(Globals.VILLAGER)

		# Limit possible rewards to those that are weighted lower than the difficulty
		for item in possible_rewards:
			if item.reward_weight > difficulty:
				possible_rewards.erase(item)

		var reward_score = -1
		while reward_score < difficulty:
			var i = possible_rewards.pick_random()
			if i.reward_weight > difficulty - reward_score:
				possible_rewards.erase(i)
				continue

			if rewards.has(i):
				rewards[i] = rewards[i] + 1
			else:
				rewards[i] = 1
			reward_score += i.reward_weight

	func set_quest_requirements():
		var crops = []

		#Erase all crops from pool with 0 inventory
		for crop in Globals.CROP_TYPES:
			var limit = Inventory.get_item_quantity(crop)
			if limit > 0:
				crops.append(crop)

		if len(crops) == 0:
			return

		var score = -1
		while score < difficulty:
			var c = crops.pick_random()
			var limit = Inventory.get_item_quantity(c)
			var amount = randi_range(ceil(limit/6), ceil(limit/4))
			if requirements.has(c):
				requirements[c] = min(requirements[c] + amount, limit/2)
			else:
				requirements[c] = amount
			score += 1

	func make_random_end_quest():
		var crops = Globals.CROP_TYPES
		for i in len(crops):
			requirements[crops[i]] = (10) * randi_range(8, 12)

		timeline = Calendar.calc_year_length() * 4

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

@tool
extends Node

@export var items : Dictionary[String, float]

@warning_ignore_start("unused_signal")
signal request_add_item
signal request_remove_item
signal request_spawn_item

signal update_ui

var available_workers : int

func _ready():
	request_add_item.connect(_on_request_add_item)
	request_remove_item.connect(_on_request_remove_item)
	request_spawn_item.connect(_on_request_spawn_item)

	#Placeholder start inventory
	update_inventory_item(load("res://Resources/Item_Plot_2.tres"), 2)
	
func _on_request_add_item(_item_data, _quantity, should_update):
	update_inventory_item(_item_data, _quantity)
	if should_update:
		update_ui.emit()
	
func _on_request_remove_item(_item_data, _quantity, should_update):
	update_inventory_item(_item_data, 0 - _quantity)
	if should_update:
		update_ui.emit()

func update_inventory_item(_item_data, _quantity):
	#Check for existing and update it
	if items.has(_item_data.item_name):
		items[_item_data.item_name] += _quantity
	else:	
	#Otherwise add an entry
		items[_item_data.item_name] = _quantity

func get_item_quantity(_item_in):
	if items.has(_item_in.item_name):
		return items[_item_in.item_name]
	else:
		return 0

func load_game(_starting_villager_count):
	add_villager(_starting_villager_count)

func request_worker(amount: int) -> bool:
	var new_total = available_workers + (0 - amount)
	if new_total >= 0 and new_total <= int(items["Villager"]):
		available_workers = new_total
		print("Take a worker, ", available_workers)
		return true
	else:
		print("No workers available, ", available_workers)
		return false

func add_villager(count):
	for i in count:
		Events.emit_signal("add_villager")

	var villager_data : ItemData = load("res://Resources/Item_Villager.tres")
	_on_request_add_item(villager_data, count, true)
	available_workers = int(items["Villager"])

func remove_villager(count):
	for i in count:
		var v = %NPCs.get_children().pick_random()
		v.queue_free()
		#TODO : Handle when villager is removed but assigned as worker

func _on_request_spawn_item(item_data):
	Events.emit_signal("add_plot", item_data)
	_on_request_remove_item(item_data, 1, true)

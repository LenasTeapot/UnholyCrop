extends Control

@export var item : ItemData
var quantity : int = 0
var show_quest : bool = false

func _ready():
	_update_icon()
	%Label.text = str(quantity)
	Inventory.update_ui.connect(_update)
	Quests.quest_updated.connect(_update)
	Events.toggle_quest_ui.connect(_toggle_quest)

func _update_icon():
	if item != null:
		%TextureRect.texture = item.icon

func _update():
	if item != null:
		quantity = int(Inventory.get_item_quantity(item))
		%Label.text = str(quantity)

	var quest = Quests.get_end_quest()
	if quest == null or !show_quest:
		return

	if quest.requirements.has(item):
		%Label.text = str(quantity, "/", int(quest.requirements[item]))

func _toggle_quest():
	show_quest = !show_quest
	_update()

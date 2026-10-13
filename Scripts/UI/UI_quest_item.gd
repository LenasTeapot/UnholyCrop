extends Control

func load_item(item : ItemData, count : int):
	%TextureRect.texture = item.icon
	%Label.text = str("X ", str(count))

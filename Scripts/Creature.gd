extends CharacterBody2D
class_name Creature

var area_detector : Area2D

func _ready():
	area_detector = find_child("AreaDetector") as Area2D
	Calendar.game_pause.connect(func(): pause_monitoring(true))
	Calendar.game_play.connect(func(): pause_monitoring(false))

func pause_monitoring(should_pause):
	if area_detector != null:
		area_detector.monitoring = !should_pause

func _physics_process(_delta):
	if velocity.x > 0:
		%Sprite.flip_h = false
	else:
		%Sprite.flip_h = true
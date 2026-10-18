extends Creature
class_name Creature_Pest

@export var direction: Vector2 = Vector2.UP
@export var speed: float = 40.0
@export var modifier : ProductionModifier

var initial_spawner: Spawner
var has_turned_around := false

func _ready():
	super()
	initial_spawner = get_parent() as Spawner
	if initial_spawner != null:
		direction = initial_spawner.get_direction_vector()
	
	$AreaDetector.area_entered.connect(_on_area_entered)

func _physics_process(_delta: float) -> void:
	super(_delta)
	velocity = direction.normalized() * speed
	move_and_slide()

func _on_area_entered(area: Area2D) -> void:
	if area == initial_spawner:
		if has_turned_around:
			queue_free()
		return
	
	if area is Spawner:
		queue_free()
		return

	if area is Placeable_Plot and modifier != null:
		area.add_modifier(modifier)

	if not has_turned_around:
		direction = -direction
		has_turned_around = true


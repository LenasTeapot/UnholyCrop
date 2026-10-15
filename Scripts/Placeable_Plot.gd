@tool
extends Placeable
class_name Placeable_Plot

@export var plot_data : ItemData_Plot:
	set(value):
		plot_data = value
		update()

@export var item : ItemData_Crop:
	set(value):
		item = value
		update()

var current_progress := 0.0
const base_array : Array[Vector2] = [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]

var workers := 0

var modifiers : Array[ProductionModifier]

func _ready():
	super()
	if plot_data == null:
		return

func _init():
	update()
	Calendar.day_end.connect(_on_day_end)
	
func update():
	if has_node("%NinePatchRect"):
		var new_size: float = 16 + plot_data.grid_size*16
		
		%NinePatchRect.size = Vector2(new_size, new_size)
		%NinePatchRect.position = Vector2(0 - new_size/2, 0 - new_size/2)
		
		%CollisionShape2D.shape = RectangleShape2D.new()
		%CollisionShape2D.shape.size = Vector2(new_size, new_size)
		
		%Outline.size = Vector2(%NinePatchRect.size.x +2, %NinePatchRect.size.y +2)
		%Outline.position = Vector2(%NinePatchRect.position.x -1, %NinePatchRect.position.y -1)

		var new_array = []
		for v in base_array:
			var new_v = Vector2(v.x * (8.0 * plot_data.grid_size + 8.0), v.y * (8.0 * plot_data.grid_size + 8.0))
			new_array.append(new_v)
		%NavigationObstacle2D.vertices = new_array

		if not item:
			return
		
		update_sprites()

func remove_plot():
	Inventory.request_add_item.emit(plot_data, 1, true)
	add_worker(0 - workers)
	queue_free()
		
func add_worker(amount): # Will also remove a worker if amount is negative
	if workers == 0 and amount <= 0:
		return
	if workers == plot_data.max_workers and amount > 0:
		return
	if Inventory.request_worker(amount): # This also updates the global count of workers
		workers = clamp(workers + amount, 0, plot_data.max_workers)
		if amount > 0:
			modifiers.append(Modifier_Worker.new())
		elif amount < 0:
			for count in abs(amount):
				for m in modifiers:
					if m is Modifier_Worker:
						modifiers.erase(m)
						break

	update_sprites()


func change_crop(new_crop_data : ItemData_Crop):
	if new_crop_data == item:
		return
	item = new_crop_data
	current_progress = 0.0
	update_sprites()

func _on_day_end(_current_day):
	### It would be good to show which crops are not growing, so player understands how many will be produced
	current_progress += 1
	if current_progress > item.growth_time:
		# TODO : Create season modifiers?
		#var mod = item.growth_modifiers[Calendar.get_current_season()] # Move to crop data class?
		produce_crop()
		current_progress = 0
	update_sprites()

func hover_begin():
	if Calendar.is_paused:
		return
	%Outline.visible = true

func hover_end():
	if Calendar.is_paused:
		return
	%Outline.visible = false

func release_hold(keep_position : bool):
	super(keep_position)
	get_parent().bake_navigation_polygon()

func first_placement():
	add_worker(1)
	#TODO : Trigger pop up??

func produce_crop():
	var amount = calculate_production()

	print("Produce ", amount, " ", item.item_name)
	Inventory.request_add_item.emit(item, amount, true)
	if amount == 0:
		return

	%GPUParticles2D.texture = item.icon
	%GPUParticles2D.amount = amount
	%GPUParticles2D.emitting = true

func calculate_production() -> int:
	var amount = 0
	for m in modifiers:
		amount = m.run(plot_data.grid_size, amount)
	return amount

func update_sprites():
	%Crop_Icon.texture = item.icon

	var children = %Plants.get_children()
	for c in children:
		c.queue_free()
	var count = 0
	var max_product = calculate_production()
	for v in range(plot_data.grid_size):
		if count >= max_product:
			break
		for h in range(plot_data.grid_size):
			var sprite = Sprite2D.new()
			sprite.texture = item.get_sprite_by_progress(current_progress)
			%Plants.add_child(sprite)
			var offset = (plot_data.grid_size/2.0)*Globals.GRID_SIZE
			sprite.position = Vector2((h * Globals.GRID_SIZE) - offset + Globals.GRID_SIZE/2, (v * Globals.GRID_SIZE) - offset + Globals.GRID_SIZE/2)
			count +=1

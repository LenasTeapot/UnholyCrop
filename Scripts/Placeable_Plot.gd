@tool
extends Placeable
class_name Placeable_Plot

@export var plot_data : ItemData_Plot:
	set(value):
		plot_data = value
		update_size()

@export var item : ItemData_Crop

var current_progress := 0.0
const base_array : Array[Vector2] = [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]

var workers := 0

var modifiers : Array[ProductionModifier]

func _ready():
	super()
	if plot_data == null:
		return

func _init():
	Calendar.day_end.connect(_on_day_end)
	
func update_size():
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
		
		update_sprites()

func remove_plot():
	Inventory.request_add_item.emit(plot_data, 1, true)
	add_worker(0 - workers)
	queue_free()

func add_modifier(mod_in):
	modifiers.append(mod_in)
	update_sprites()
		
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
	current_progress += 1
	if current_progress > item.growth_time:
		# TODO : Create season modifiers?
		#var mod = item.growth_modifiers[Calendar.get_current_season()] # Move to crop data class?
		produce_crop()
		current_progress = 0

	update_sprites()

	var mods = []
	for m in modifiers:
		mods.append(get_object_class_name(m))
	print(mods)

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
	remove_temp_modifiers()

	print("Produce ", amount, " ", item.item_name)
	Inventory.request_add_item.emit(item, amount, true)

	if amount <= 0:
		return
	%GPUParticles2D.texture = item.icon
	%GPUParticles2D.amount = amount
	%GPUParticles2D.emitting = true

func calculate_production() -> int:
	#TODO : Should adding a worker only increase yield if they are there for the full production cycle?
	var amount = 0
	for m in modifiers:
		amount = m.run(plot_data.grid_size, amount)
	return max(amount, 0)

func remove_temp_modifiers():
	for m in modifiers:
		if m.temporary:
			modifiers.erase(m)

func update_sprites():
	# TODO: Have a way to track individual tiles.
	if not item:
		return

	# Update UI Icon
	%Crop_Icon.texture = item.icon

	# Update sprites in the plot's field
	var children = %Plants.get_children()
	for c in children:
		c.queue_free()
	var count = 0
	var max_product = calculate_production()
	for v in range(plot_data.grid_size):
		for h in range(plot_data.grid_size):
			if count >= max_product:
				break
			var sprite = Sprite2D.new()
			sprite.texture = item.get_sprite_by_progress(current_progress)
			%Plants.add_child(sprite)
			var offset = (plot_data.grid_size/2.0)*Globals.GRID_SIZE
			sprite.position = Vector2((h * Globals.GRID_SIZE) - offset + Globals.GRID_SIZE/2, (v * Globals.GRID_SIZE) - offset + Globals.GRID_SIZE/2)
			count +=1

func get_object_class_name(obj: Object) -> String:
	if obj == null:
		return ""
		
	var script = obj.get_script()
	if script and script.has_method("get_global_name"):
		var custom_name = script.get_global_name()
		if custom_name != "":
			return custom_name
			
	# Fallback to the native engine class name (e.g., "Node2D", "Sprite2D")
	return obj.get_class() 
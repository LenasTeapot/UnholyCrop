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

var workers : int = 0

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
		
func add_worker(amount):
	### TODO: Create a modifier for workers, and apply to crop production
	if workers == 0 and amount <= 0:
		return
	if workers == plot_data.grid_size and amount > 0:
		return
	if Inventory.request_worker(amount): # This also updates the global count of wokers
		workers = clamp(workers + amount, 0, plot_data.grid_size)
		# TODO: Make worker move to plot and move around it???

func change_crop(new_crop_data : ItemData_Crop):
	item = new_crop_data
	current_progress = 0.0
	update_sprites()

func _on_day_end(_current_day):
	### It would be good to show which crops are not growing, so player understands how many will be produced

	var mod = item.growth_modifiers[Calendar.get_current_season()] # Move to crop data class?
	current_progress += 1
	if current_progress > item.growth_time:
		produce_crop((plot_data.grid_size * plot_data.grid_size) * mod)
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

func produce_crop(amount):
	print("Produce ", amount, " ", item.item_name)
	Inventory.request_add_item.emit(item, amount, true)
	%GPUParticles2D.texture = item.icon
	%GPUParticles2D.amount = amount
	%GPUParticles2D.emitting = true

func update_sprites():
	var children = %Plants.get_children()
	for c in children:
		c.queue_free()
	for v in range(plot_data.grid_size):
		for h in range(plot_data.grid_size):
			var sprite = Sprite2D.new()
			sprite.texture = item.get_sprite_by_progress(current_progress)
			%Plants.add_child(sprite)
			var offset = (plot_data.grid_size/2.0)*Globals.GRID_SIZE
			sprite.position = Vector2((h * Globals.GRID_SIZE) - offset + Globals.GRID_SIZE/2, (v * Globals.GRID_SIZE) - offset + Globals.GRID_SIZE/2)

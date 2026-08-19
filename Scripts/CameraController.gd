extends Camera2D

@export var start_position := Vector2.ZERO

var pan_start_mouse_pos = Vector2.ZERO
var pan_start_camera_pos = Vector2.ZERO
var is_mouse_panning = false

const ZOOM_IN_SPEED: float = 1.1
const ZOOM_OUT_SPEED: float = 0.9
const MIN_ZOOM: float = 3.5
const MAX_ZOOM: float = 0.2
@export var MAX_WIDTH := 360.0
@export var MAX_HEIGHT := 360.0
@export var kb_pan_speed := 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	#Events.connect("new_game", on_load_new_game)
	#Events.connect("load_game", on_load_new_game)
	enabled = true
	
func on_load_new_game():
	zoom.x = 1
	zoom.y = 1
	position = start_position
	use_cam(false)
	
func use_cam(shouldUse):
	if shouldUse:
		enabled = true
		make_current()
	else:
		enabled = false
	get_child(0).visible = enabled

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if enabled:
		#Zoom()
		Pan()

func Zoom():
	if Input.is_action_just_pressed("camera_zoom_in") and enabled == true:
		zoom.x = minf(MIN_ZOOM, zoom.x * ZOOM_IN_SPEED)
		zoom.y = zoom.x
	if Input.is_action_just_pressed("camera_zoom_out") and enabled == true:
		zoom.x = maxf(MAX_ZOOM, zoom.x * ZOOM_OUT_SPEED)
		zoom.y = zoom.x

func Pan():
	# Mouse panning
	if not is_mouse_panning && (Input.is_action_just_pressed("camera_pan")):
		pan_start_mouse_pos = get_viewport().get_mouse_position()
		pan_start_camera_pos = position 
		is_mouse_panning = true
		
	if is_mouse_panning && (Input.is_action_just_released("camera_pan")):
		is_mouse_panning = false
		
	if is_mouse_panning:
		var delta_vector = get_viewport().get_mouse_position() - pan_start_mouse_pos
		var new_pos = pan_start_camera_pos - delta_vector * 1/zoom.x
		pan_camera(new_pos)
		return
	
	# Keyboard panning
	if not is_mouse_panning:
		var new_pos : Vector2
		if Input.is_action_pressed("pan_down"):
			new_pos = Vector2(position.x, position.y + 1 *  kb_pan_speed)
			pan_camera(new_pos)
		if Input.is_action_pressed("pan_up"):
			new_pos = Vector2(position.x, position.y - 1 *  kb_pan_speed)
			pan_camera(new_pos)
		if Input.is_action_pressed("pan_left"):
			new_pos = Vector2(position.x - 1 *  kb_pan_speed, position.y)
			pan_camera(new_pos)
		if Input.is_action_pressed("pan_right"):
			new_pos = Vector2(position.x + 1 *  kb_pan_speed, position.y)
			pan_camera(new_pos)
		
func pan_camera(new_pos : Vector2):
	# Final camera pan calculations
	position = Vector2(clampf(new_pos.x, 0 - MAX_WIDTH, MAX_WIDTH), clampf(new_pos.y, 0 - MAX_HEIGHT, MAX_HEIGHT))

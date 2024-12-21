extends Camera3D

var is_focused : bool = true:
	set(_is_focused):
		is_focused = _is_focused
		
		if _is_focused == true:
			if OS.has_feature("web"):
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

@export var fly_speed : float = 5
@export var fly_speed_increment : float = 1
@export var fly_speed_max : float = 100
@export var fly_speed_min : float = 1
@export var max_pitch_angle : float = 1.5  # Max pitch angle in radians (~85 degrees)

var rotate_input_mouse : Vector2 = Vector2.ZERO

func _ready() -> void:
	is_focused = false


func _process(delta: float) -> void:
	if not is_focused:
		return

	# Fly movement
	var fly_horizontal_input : Vector2 = Input.get_vector("camera_left", "camera_right", "camera_forward", "camera_backward")
	var fly_vertical_input : float = Input.get_axis("camera_down", "camera_up")
	var fly_input = Vector3(fly_horizontal_input.x, fly_vertical_input, fly_horizontal_input.y)

	translate(fly_input * fly_speed * delta)

	# Mouse rotation
	var yaw = -rotate_input_mouse.x * Settings.mouse_sensitivity * delta
	var pitch = -rotate_input_mouse.y * Settings.mouse_sensitivity * delta
	
	# Rotate camera around the Y axis (yaw)
	rotate(Vector3.UP, yaw)
	
	# Rotate camera around the local X axis (pitch), with limits
	var current_pitch = global_transform.basis.get_euler().x
	var new_pitch = current_pitch + pitch
	if new_pitch > -max_pitch_angle and new_pitch < max_pitch_angle:
		rotate(global_transform.basis.x, pitch)
		
	rotate_input_mouse = Vector2.ZERO
	

func _input(event: InputEvent) -> void:
	# Adjust fly speed with input
	if event.is_action("increase_fly_speed"):
		if fly_speed + fly_speed_increment <= fly_speed_max:
			fly_speed += fly_speed_increment
	
	if event.is_action("decrease_fly_speed"):
		if fly_speed - fly_speed_increment >= fly_speed_min:
			fly_speed -= fly_speed_increment
			
	if event.is_action_pressed("camera_exit"):
		is_focused = false
	if event.is_action_pressed("camera_focus"):
		if is_focused:
			is_focused = false
		else:
			is_focused = true

	if event is InputEventMouseMotion:
		rotate_input_mouse = event.get_screen_relative()
		

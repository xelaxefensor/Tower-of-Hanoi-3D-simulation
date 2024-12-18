extends Node3D

var step : int = 0
var previous_step
var next_step

var is_anim_paused = true
enum anim_state {STEPPING_FORWARD, IDLE, STEPPING_BACKWARD}
var current_anim_state = anim_state.IDLE
var anim_speed : float = 1	

@export var speed_line_edit : LineEdit

@export var disk_prefab : PackedScene
@export var disk_mesh : CylinderMesh
@export var rod_prefab : PackedScene
@export var rod_mesh : CylinderMesh
var disk_materials_var = "res://disk/materials/"
var disk_materials = []

var smallest_disk_radius : float = 1
var biggest_disk_radius : float = 5
var disk_radius_increment : float = 0.2
var disk_height : float = 0.2
var disks = []

var rod_radius : float = 0.1
var rod_height : float = 2
var distance_between_rods : float = 1
var rods_position = []




func set_up_animation():
	if not Hanoi.calculated:
		return
	
	step = 0
	calc_steps()
	
	
func calc_steps():
	if step > 0:
		previous_step = Hanoi.hanoi_moves[step-1]
	if Hanoi.hanoi_moves.size() > step:
		next_step = Hanoi.hanoi_moves[step]
	
	print(previous_step)
	print(next_step)
	
	
func calc_biggest_disk_radius():
	biggest_disk_radius = smallest_disk_radius + (Hanoi.number_of_disks - 1) * disk_radius_increment
	
	
func calc_rod_height():
	rod_height = (Hanoi.number_of_disks+1) * disk_height


func calc_distance_between_rods():
	distance_between_rods = biggest_disk_radius*2
	

func calc_rods_position():
	calc_distance_between_rods()
	
	var y = rod_height / 2
	var z = 0
	
	var x_lenght = distance_between_rods * Hanoi.number_of_rods - 1
	var x_first = 0 - x_lenght / 2
	
	for i in Hanoi.number_of_rods:
		var x = x_first + i * distance_between_rods
		rods_position.append(Vector3(x,y,z))
		

func draw_rods():
	var mesh : CylinderMesh = rod_mesh
	mesh.bottom_radius = rod_radius
	mesh.top_radius = rod_radius
	mesh.height = rod_height
	
	
	for i in Hanoi.number_of_rods:
		var spawn : MeshInstance3D = rod_prefab.instantiate()
		
		spawn.set_mesh(mesh)
		
		spawn.position = rods_position[i-1]
		
		$Rods.add_child(spawn)
		
		
func set_up_disk_materials():
	var dir = DirAccess.open(disk_materials_var)
	
	for file in dir.get_files():
		disk_materials.append(load(disk_materials_var+file))


func draw_disks():
	set_up_disk_materials()
	var num_of_colors = disk_materials.size()
	
	for i in Hanoi.number_of_disks:
		var spawn : MeshInstance3D = disk_prefab.instantiate()
		var mesh = disk_mesh.duplicate()
		mesh.bottom_radius = biggest_disk_radius - i * disk_radius_increment
		mesh.top_radius = biggest_disk_radius - i * disk_radius_increment
		mesh.height = disk_height
		
		spawn.set_mesh(mesh)
		spawn.material_override = disk_materials[i % num_of_colors]
		
		spawn.position = rods_position[Hanoi.starting_rod] + Vector3(0, disk_height * i - rod_height/2 + disk_height/2, 0)
		
		disks.append(spawn)
		$Rods.add_child(spawn)
		
		
func reset():
	step = 0
	previous_step = null
	next_step = null

	is_anim_paused = true
	current_anim_state = anim_state.IDLE

	disk_materials = []
	disks = []

	distance_between_rods = 1
	rods_position = []
	
	
	for i in $Rods.get_children():
		i.queue_free()
	
	for i in $Disks.get_children():
		i.queue_free()
	
	
func _on_button_pressed() -> void:
	reset()
	calc_biggest_disk_radius()
	calc_rod_height()
	calc_rods_position()
	draw_rods()
	draw_disks()
	set_up_animation()


func _on_play_pause_pressed() -> void:
	if not Hanoi.calculated:
		return
		
	if is_anim_paused:
		is_anim_paused = false
	else:
		is_anim_paused = true


func _on_previous_pressed() -> void:
	if not Hanoi.calculated:
		return


func _on_next_pressed() -> void:
	if not Hanoi.calculated:
		return


func _on_line_edit_text_submitted(new_text: String) -> void:
	if not new_text.is_valid_float():
		speed_line_edit.text = ""
		speed_line_edit.placeholder_text =  str(anim_speed)
		return

	if not new_text.to_float() > 0:
		speed_line_edit.text = ""
		speed_line_edit.placeholder_text =  str(anim_speed)
		return

	anim_speed = new_text.to_float()
	speed_line_edit.placeholder_text = new_text
	speed_line_edit.text = ""
	
	$AnimationPlayer.speed_scale = anim_speed


func _on_sub_viewport_container_mouse_clicked() -> void:
	$Camera.is_focused = true

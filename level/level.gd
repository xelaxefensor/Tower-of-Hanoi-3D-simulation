extends Node3D

var is_set_upped : bool = false

var step : int = 0
var previous_step
var next_step

@onready var anim_player : AnimationPlayer = $AnimationPlayer
var is_anim_paused : bool = true:
	set(val):
		is_anim_paused = val
		if val == true:
			anim_player.pause()
		else:
			anim_player.play("Disk")
enum anim_state {STEPPING_FORWARD, IDLE, STEPPING_BACKWARD}
var current_anim_state = anim_state.IDLE
var anim_speed_scale : float = 1

@export var speed_line_edit : LineEdit

@onready var wait_time_between_steps_timer = $TimerBetweenSteps
var wait_time_between_steps : float = 0.5
var disk_move_speed : float = 20

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

var current_disks_position = []
var next_disks_position = []
var selected_disk
var disk_keyframe_positions = []
var distance_between_keyframes = []
var overall_keyframe_distance : float = 0
var def_animation_speed : float = 1
var animation : Animation = Animation.new()
var track_idx = animation.add_track(Animation.TYPE_POSITION_3D)


func set_up_animation():
	if not Hanoi.calculated:
		return
		
	reset()
	calc_biggest_disk_radius()
	calc_rod_height()
	calc_rods_position()
	draw_rods()
	draw_disks()	
	
	step = 0
	calc_steps()
	
	current_disks_position = []
	next_disks_position = []
	disk_keyframe_positions = []
	distance_between_keyframes = []
	
	animation.clear()
	
	for x in Hanoi.number_of_rods:
		current_disks_position.append([])
	for x in Hanoi.number_of_disks:
		current_disks_position[Hanoi.starting_rod].append(x)
		
	calc_next_disks_position(next_step.x, next_step.y)
	calc_disk_to_anim(next_step.x)
	calc_disk_keyframe_positions(next_step.x , next_step.y)
	create_animation()
	is_set_upped = true
	
	
func calc_disk_to_anim(from : int):
	if from != null and current_disks_position[from].size() != 0:
		selected_disk = disks[current_disks_position[from].back()]
		
		
func calc_next_disks_position(from : int, to : int):
	next_disks_position = current_disks_position.duplicate(true)
	next_disks_position[to].push_back(next_disks_position[from].pop_back())
	
	
func calc_steps():
	if not step <= Hanoi.hanoi_moves.size():
		return
	
	if step > 0:
		previous_step = Hanoi.hanoi_moves[step-1]
	if Hanoi.hanoi_moves.size() > step:
		next_step = Hanoi.hanoi_moves[step]
		
		
func calc_disk_keyframe_positions(from : int, to : int):
	disk_keyframe_positions = []
	disk_keyframe_positions.append(selected_disk.position)
	disk_keyframe_positions.append(Vector3(rods_position[from].x, rod_height + disk_height, 0))
	disk_keyframe_positions.append(Vector3(rods_position[to].x, rod_height + disk_height, 0))
	disk_keyframe_positions.append(Vector3(rods_position[to].x, disk_height/2 + current_disks_position[to].size() * disk_height, 0))
	calc_distance_between_keyframes()
	
	
func calc_distance_between_keyframes():
	distance_between_keyframes = []
	overall_keyframe_distance = 0
	for i in disk_keyframe_positions.size()-1:
		var x = disk_keyframe_positions[i].distance_to(disk_keyframe_positions[i+1])
		distance_between_keyframes.append(x)
		overall_keyframe_distance += x
		
		
func create_animation():
	animation.clear()
	anim_player.stop()
	track_idx = animation.add_track(Animation.TYPE_POSITION_3D)
	var node_path = "Disks/"+selected_disk.name
	animation.track_set_path(track_idx, node_path)
	
	var distance = 0
	for i in range(disk_keyframe_positions.size()):
		if i == 0:
			animation.track_insert_key(track_idx, 0, disk_keyframe_positions[i])
		else:
			animation.track_insert_key(track_idx, distance + distance_between_keyframes[i-1], disk_keyframe_positions[i])
			distance += distance_between_keyframes[i-1]
	
	animation.length = overall_keyframe_distance
	
	var anim_library = anim_player.get_animation_library(anim_player.get_animation_library_list().front())
	if anim_library.has_animation("Disk"):
		anim_library.remove_animation("Disk")
	anim_library.add_animation("Disk", animation)
	
		
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
	
	var x_lenght = distance_between_rods * (Hanoi.number_of_rods - 1)
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
		$Disks.add_child(spawn)
		
		
func reset():
	is_anim_paused = true
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
	

func _on_play_pause_pressed() -> void:
	if not Hanoi.calculated:
		return
		
	if not is_set_upped:
		return
		
	if current_anim_state == anim_state.IDLE:
		current_anim_state = anim_state.STEPPING_FORWARD
		do_next_step()
		
	if is_anim_paused:
		is_anim_paused = false
	else:
		is_anim_paused = true


func _on_previous_pressed() -> void:
	if not Hanoi.calculated:
		return

	if not is_set_upped:
		return
		
	if not step > 0:
		return
		
	if current_anim_state == anim_state.STEPPING_FORWARD:
		current_anim_state = anim_state.IDLE
		is_anim_paused = true
		selected_disk.position = disk_keyframe_positions[0]
		change_current_step()
	elif current_anim_state == anim_state.IDLE:
		current_anim_state = anim_state.STEPPING_BACKWARD
		is_anim_paused = true
		calc_disk_to_anim(previous_step.y)
		calc_disk_keyframe_positions(previous_step.y , previous_step.x)
		selected_disk.position = disk_keyframe_positions[3]
		calc_next_disks_position(previous_step.y, previous_step.x)
		change_current_step()
		

func _on_next_pressed() -> void:
	if not Hanoi.calculated:
		return
		
	if not is_set_upped:
		return
		
	if not step < Hanoi.hanoi_moves.size():
		return	
	
	if current_anim_state == anim_state.STEPPING_FORWARD:
		is_anim_paused = true
		selected_disk.position = disk_keyframe_positions[3]
		change_current_step()
	elif current_anim_state == anim_state.IDLE:
		current_anim_state = anim_state.STEPPING_FORWARD
		is_anim_paused = true
		calc_disk_to_anim(next_step.x)
		calc_disk_keyframe_positions(next_step.x , next_step.y)
		selected_disk.position = disk_keyframe_positions[3]
		change_current_step()
	

func _on_line_edit_text_submitted(new_text: String) -> void:
	if not new_text.is_valid_float():
		speed_line_edit.text = ""
		speed_line_edit.placeholder_text =  str(anim_speed_scale)
		return

	if not new_text.to_float() > 0:
		speed_line_edit.text = ""
		speed_line_edit.placeholder_text =  str(anim_speed_scale)
		return

	anim_speed_scale = new_text.to_float()
	speed_line_edit.placeholder_text = new_text
	speed_line_edit.text = ""
	
	$AnimationPlayer.speed_scale = anim_speed_scale


func _on_sub_viewport_container_mouse_clicked() -> void:
	$Camera.is_focused = true


func _ready() -> void:
	Hanoi.hanoi_calculated.connect(on_hanoi_calculated)
	
	
func on_hanoi_calculated():
	set_up_animation()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	change_current_step()		
	
	
func change_current_step():
	if current_anim_state == anim_state.IDLE:
		return
		
	current_disks_position = next_disks_position
	
	if current_anim_state == anim_state.STEPPING_FORWARD:
		step += 1
	if current_anim_state == anim_state.STEPPING_BACKWARD:
		step -= 1
		
	calc_steps()
	#if current_anim_state == anim_state.STEPPING_FORWARD:
	#	calc_next_disks_position(next_step.x, next_step.y)
	#if current_anim_state == anim_state.STEPPING_BACKWARD:
	#	calc_next_disks_position(previous_step.y, previous_step.x)
		
	calc_next_disks_position(next_step.x, next_step.y)
		
	current_anim_state = anim_state.IDLE
	
	if not is_anim_paused:
		do_next_step()
	
	
func do_next_step():
	if not step < Hanoi.hanoi_moves.size():
		return
	
	current_anim_state = anim_state.STEPPING_FORWARD
	calc_next_animation()
	anim_player.play("Disk")


func calc_next_animation():
	calc_next_disks_position(next_step.x, next_step.y)
	calc_disk_to_anim(next_step.x)
	calc_disk_keyframe_positions(next_step.x , next_step.y)
	create_animation()

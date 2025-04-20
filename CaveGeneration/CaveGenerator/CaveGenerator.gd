extends Node3D

@export
var voxel_terrain : VoxelTerrain

@onready
var voxel_tool : VoxelTool = voxel_terrain.get_voxel_tool()

@export
var generation_start_marker : Marker3D

@onready
var current_walker : Node3D = $CurrentWalker

@export
var random_walk_length : int = 100

@export
var removal_size : float = 2.0

@export
var ceiling_thickness_m : int = 5

@onready
var crystal_preload : PackedScene = preload("res://CaveAdditions/Crystal/Crystal.tscn")

var random_walk_positions : Array[Vector3] = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	setup()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("cave_gen"):
		random_walk()

func setup():
	current_walker.transform = generation_start_marker.transform

func random_walk():
	
	for i in range(random_walk_length):
		
		# Move the random walker to the new position:
		current_walker.global_position += get_random_direction()
		
		# Clamp the height to prevent above ground
		current_walker.global_position.y = clampf(current_walker.global_position.y, -1000, voxel_terrain.generator.height - ceiling_thickness_m)
		
		# Store the walk positions
		random_walk_positions.append(current_walker.global_position)
		
		# Carve out a chunk at our current position
		do_sphere_removal()
		
		# Get a random position on the wall, and add geometry there if valid
		var wall_point = get_random_wall_point()
		if wall_point:
			do_sphere_addition(wall_point)

	# Once generation is finished, revisit previous locations and add things on the wall.
	wall_additions_pass()

func wall_additions_pass():
	
	for walk_position : Vector3 in random_walk_positions:
		
		var raycast_result : VoxelRaycastResult = voxel_tool.raycast(walk_position, get_random_direction(true), 20)
		
		if raycast_result:
			
			# Create new crystal
			var new_crystal_instance : Node3D = crystal_preload.instantiate()
			self.add_child(new_crystal_instance)
			
			new_crystal_instance.global_position = raycast_result.position
			new_crystal_instance.scale = new_crystal_instance.scale * randf_range(1, 2.0)
			new_crystal_instance.look_at(new_crystal_instance.global_position + raycast_result.normal)

# Removal size returns the removal size with a small randomization
# Currently that is removal size =- removal_size * 0.25
func get_removal_size(variance : float = 1):
	
	return removal_size + randf_range(-removal_size * variance, removal_size * variance)

func get_random_wall_point():
	
	var raycast_result : VoxelRaycastResult = voxel_tool.raycast($CurrentWalker.global_position, get_random_direction(true), 20)

	if raycast_result:
		return raycast_result.position
	else:
		return null
	
func do_sphere_removal():
	voxel_tool.mode = VoxelTool.MODE_REMOVE
	
	voxel_tool.do_sphere($CurrentWalker.global_position, get_removal_size())

func do_sphere_addition(global_point : Vector3 = Vector3.ZERO):
	voxel_tool.mode = VoxelTool.MODE_ADD
	
	voxel_tool.do_sphere(global_point, get_removal_size(2) / removal_size)

func get_random_direction(use_float : bool = false):
	
	var direction_vector : Vector3
	
	# Omniderectional with float
	if use_float:
		direction_vector = Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
	else:
		# 9 directions with int
		direction_vector = Vector3([-1,0,1].pick_random(),[-1,0,1].pick_random(),[-1,0,1].pick_random())
	
	var vector_with_magnitude : Vector3 = direction_vector * removal_size
	
	return direction_vector

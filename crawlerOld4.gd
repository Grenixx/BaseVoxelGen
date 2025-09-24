extends CharacterBody3D

@export var move_speed: float = 3.0
@export var hover_height: float = 1.0
@export var hover_smooth: float = 8.0
@export var ray_length: float = 3.0

var local_down: Vector3 = Vector3.DOWN

func _physics_process(delta: float) -> void:
	var forward = -global_transform.basis.z
	velocity = forward * move_speed

	var space_state = get_world_3d().direct_space_state

	# Ray principal vers le bas local
	var ray_from = global_position
	var ray_to = global_position + local_down * ray_length
	var result = space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(ray_from, ray_to, collision_mask)
	)

	# Si pas de sol → on check devant
	if not result:
		var ray_forward = global_position + forward * ray_length
		result = space_state.intersect_ray(
			PhysicsRayQueryParameters3D.create(ray_from, ray_forward, collision_mask)
		)

	if result:
		var ground_pos = result.position
		var ground_normal = result.normal

		# update du "down" local basé sur la normale trouvée
		local_down = -ground_normal

		# position flottante
		var target_pos = ground_pos + ground_normal * hover_height
		global_position = global_position.lerp(target_pos, delta * hover_smooth)

		# alignement avec la surface
		look_at(global_position + forward, ground_normal)

	move_and_slide()

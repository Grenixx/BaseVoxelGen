extends CharacterBody3D

@export var move_speed: float = 3.0
@export var hover_height: float = 1.0
@export var hover_smooth: float = 8.0
@export var ray_length: float = 3.0
@export var gravity: float = 9.8

var local_down: Vector3 = Vector3.DOWN
var attached: bool = true

func _physics_process(delta: float) -> void:
	var forward = -global_transform.basis.z
	var space_state = get_world_3d().direct_space_state

	# direction de recherche (mélange entre avancer et coller au sol)
	var ray_dir = (forward + local_down).normalized()
	var ray_from = global_position
	var ray_to = global_position + ray_dir * ray_length

	var result = space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(ray_from, ray_to, collision_mask)
	)

	if result:
		attached = true
		var ground_pos = result.position
		var ground_normal = result.normal

		# update du "down"
		local_down = -ground_normal

		# avancer le long de la surface
		velocity = forward * move_speed

		# snap avec hauteur
		var target_pos = ground_pos + ground_normal * hover_height
		global_position = global_position.lerp(target_pos, delta * hover_smooth)

		# alignement orientation
		look_at(global_position + forward, ground_normal)
	else:
		# rien détecté => chute
		if attached:
			attached = false
			local_down = Vector3.DOWN  # reset gravité monde

		velocity.y -= gravity * delta

	move_and_slide()

extends CharacterBody3D

@export var move_speed: float = 3.0
@export var hover_height: float = 1.0
@export var hover_smooth: float = 8.0

# direction de la "gravité locale" (au départ vers -Y)
var local_down: Vector3 = Vector3.DOWN

func _physics_process(delta: float) -> void:
	# Avancer dans l'axe -Z local
	var forward = -global_transform.basis.z
	velocity = forward * move_speed

	# Raycast dynamique (dans la direction du "down" local)
	var space_state = get_world_3d().direct_space_state
	var ray_from = global_position
	var ray_to = global_position + local_down * 5.0  # longueur du rayon

	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_from, ray_to, collision_mask))

	if result:
		var ground_pos = result.position
		var ground_normal = result.normal

		# mise à jour du "down" local pour coller au terrain
		local_down = -ground_normal

		# position désirée (au-dessus de la surface détectée)
		var target_pos = ground_pos + ground_normal * hover_height
		global_position = global_position.lerp(target_pos, delta * hover_smooth)

		# alignement orientation : 
		# - forward garde sa direction
		# - up devient la normale du terrain
		look_at(global_position + forward, ground_normal)

	move_and_slide()

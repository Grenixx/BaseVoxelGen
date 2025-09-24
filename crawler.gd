extends CharacterBody3D

@export var move_speed := 3.0
@export var hover_height := 0.5
@export var hover_smooth := 8.0
@export var ray_length := 2.0
@export var gravity := 9.8

var attached := true
var local_down := Vector3.DOWN

func _physics_process(delta: float) -> void:
	var forward = -global_transform.basis.z
	var space_state = get_world_3d().direct_space_state

	# rayon directement dans la direction "down locale"
	var ray_from = global_position
	var ray_to = ray_from + local_down * ray_length

	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_from
	params.to = ray_to
	params.exclude = [self]

	var hit = space_state.intersect_ray(params)

	if hit:
		attached = true
		var normal = hit.normal
		local_down = -normal

		# projeter le forward sur le plan tangent pour grimper murs
		var forward_on_plane = forward.slide(normal).normalized()
		velocity = forward_on_plane * move_speed

		# snap sur la surface
		var target_pos = hit.position + normal * hover_height
		global_position = global_position.lerp(target_pos, delta * hover_smooth)

		# orienter selon la normale
		look_at(global_position + forward_on_plane, normal)

	else:
		# pas de surface → chute
		if attached:
			attached = false
			local_down = Vector3.DOWN
		velocity += local_down * gravity * delta

	move_and_slide()

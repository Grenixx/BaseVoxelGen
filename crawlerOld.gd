extends CharacterBody3D

@export var move_speed: float = 2.0
@export var hover_height: float = 1.5
@export var hover_smooth: float = 5.0  # plus grand = plus rapide à corriger la hauteur
@onready var ground_ray: RayCast3D = $RayCast3D

func _physics_process(delta: float) -> void:
	# direction avant (local -Z)
	var forward = -global_transform.basis.z
	velocity = forward * move_speed
	
	# détection du terrain
	if ground_ray.is_colliding():
		var ground_pos = ground_ray.get_collision_point()
		var ground_normal = ground_ray.get_collision_normal()
		
		# position désirée au-dessus du terrain
		var target_pos = ground_pos + ground_normal * hover_height
		
		# interpolation douce vers la hauteur désirée
		global_position = global_position.lerp(target_pos, delta * hover_smooth)
		
		# rotation alignée au sol (utile si tu veux que la sphère "suit" les pentes)
		look_at(global_position + forward, ground_normal)
	
	# appliquer mouvement
	move_and_slide()

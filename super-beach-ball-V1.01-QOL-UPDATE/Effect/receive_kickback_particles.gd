extends GPUParticles3D

func direction(dir):
	if dir == -1:
		process_material.direction = Vector3(-1, 0.7, 0)
	elif dir == 1:
		process_material.direction = Vector3(1, 0.7, 0)
	await get_tree().create_timer(0.6).timeout
	queue_free()

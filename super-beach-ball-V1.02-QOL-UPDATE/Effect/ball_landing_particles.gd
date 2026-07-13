extends GPUParticles3D

func direction(dir : Vector2, speed):
	process_material.direction = Vector3(dir.x, dir.y, 0)
	amount = round(speed)
	await get_tree().create_timer(1.3).timeout
	queue_free()

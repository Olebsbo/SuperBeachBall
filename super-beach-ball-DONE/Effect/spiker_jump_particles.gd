extends GPUParticles3D

func _ready():
	await get_tree().create_timer(1.3).timeout
	queue_free()

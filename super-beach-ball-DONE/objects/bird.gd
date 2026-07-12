extends CharacterBody3D
var speed : float
var direction : int

func _ready():
	speed = randf_range(2, 2.5)
	var dir_selection = randi_range(0, 1)
	if dir_selection == 0:
		direction = -1
	else:
		direction = 1
	$AnimatedSprite3D.frame = randi_range(0, 4)

func _physics_process(_delta: float) -> void:
	$AnimatedSprite3D.play("Fly")
	velocity.x = speed * direction
	move_and_slide()

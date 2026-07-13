extends CharacterBody3D
var speed : int
var direction : int
var visible_ship : Sprite3D

func _ready():
	$Cruise.visible = false
	$Cargo.visible = false
	$Fishing.visible = false
	$Pirate.visible = false
	$Sail.visible = false
	$Speed.visible = false
	var boat_type = randi_range(0, 100)
	if boat_type == 0:
		$Pirate.visible = true
		visible_ship = $Pirate
	elif boat_type > 0 and boat_type <= 3:
		$Cruise.visible = true
		visible_ship = $Cruise
	elif boat_type > 5 and boat_type <= 5:
		$Cargo.visible = true
		visible_ship = $Cargo
	elif boat_type > 15 and boat_type <= 30:
		$Fishing.visible = true
		visible_ship = $Fishing
	elif boat_type > 40 and boat_type <= 55:
		$Speed.visible = true
		visible_ship = $Speed
	else:
		$Sail.visible = true
		visible_ship = $Sail
	speed = randi_range(1, 3)
	var dir_selection = randi_range(0, 1)
	if dir_selection == 0:
		direction = -1
		visible_ship.flip_h = not visible_ship.flip_h
	else:
		direction = 1
	
func _physics_process(_delta: float) -> void:
	velocity.x = speed * direction
	move_and_slide()

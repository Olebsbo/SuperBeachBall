extends CharacterBody3D
@export var land_zone : Sprite3D
@export var enemy_spiker : CharacterBody3D
@export var speed = 15
var received = false

func _physics_process(_delta: float) -> void:
	if Global.point_won == false:
		if Global.receive_pause == false and Global.spike_pause == false:
			#Resets received variable after ball goes over
			if Global.net_side == -1:
				received = false
			#Moves towards where the ball will land to receive
			var distance = land_zone.ball_pos_x - global_position.x
			var direction = sign(distance)
			if abs(distance) < 1:
				velocity.x = 0
			
			if land_zone.visible == true and land_zone.ball_pos_x > -0.5 and received == false:
				velocity.x = speed * direction
				if abs(distance) < 1:
					velocity.x = 0
				else:
					if direction == 1:
						$Sprite3D.flip_h = false
					else:
						$Sprite3D.flip_h = true
				$ReceiveArea/CollisionShape3D.disabled = false
			#Accounts for edge case when ball hits top of net and bounces, continues to move toward the ball.
			#Fails if the land_zone stops being visible before ball finds its final location.
			if land_zone.visible == true and received == false and abs(land_zone.update_pos_x - land_zone.ball_pos_x) > 3:
				var update_distance = land_zone.update_pos_x - global_position.x
				direction = sign(update_distance)
				velocity.x = speed * direction 
				if abs(update_distance) < 1:
					velocity.x = 0
				else:
					if direction == 1:
						$Sprite3D.flip_h = false
					else:
						$Sprite3D.flip_h = true
				$ReceiveArea/CollisionShape3D.disabled = false
		
			#gravity
			velocity.y -= 1
		else:
			$Sprite3D.flip_h = true
		move_and_slide()
	else:
		$ReceiveArea/CollisionShape3D.disabled = true
		velocity.x = 0
		velocity.y -= 1
		move_and_slide()
	animation()
	

func animation():
	if Global.receive_pause:
		if Global.net_side == 1:
			$AnimationPlayer.play("ReceiveBack")
			$Sprite3D.flip_h = true
		else:
			$AnimationPlayer.play("Ready")
	elif Global.spike_pause:
		if Global.net_side == -1:
			$AnimationPlayer.play("Ready")
		else:
			$AnimationPlayer.play("Idle")
	else:
		if abs(velocity.x) > 2:
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("Ready")

#Prevents multiple calculations of receive
func _on_receive_area_body_entered(_body: Node3D) -> void:
	Global.enemy_status = 1
	$ReceiveArea/CollisionShape3D.disabled = true
	enemy_spiker.spike()
	received = true
	velocity.x = 0

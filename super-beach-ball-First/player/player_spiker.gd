extends CharacterBody3D
@export var speed = 12
var direction = 1
var processing = false
var gravity = 0.5
var jumping = false
var spike_finish = false


func _physics_process(_delta: float) -> void:
	if Global.point_won == false:
		if Global.receive_pause == false and Global.spike_pause == false:
			#Only can control if the player has received the ball
			if processing:
				if jumping and is_on_floor() or Global.net_side == 1:
					jumping = false
					$SpikeArea/CollisionShape3D.disabled = true
					Global.player_status = 0
				#Movement
				if jumping == false and Global.player_status == 1:
					if Input.is_action_just_pressed("a"):
						direction = -1
					elif Input.is_action_just_pressed("d"):
						direction = 1
					elif Input.is_action_just_released("a") and Input.is_action_pressed("d"):
						direction = 1
					elif Input.is_action_just_released("d") and Input.is_action_pressed("a"):
						direction = -1
					
					if direction == 1:
						$Sprite3D.flip_h = false
					else:
						$Sprite3D.flip_h = true
					
					if Input.is_action_pressed("a") and direction == -1:
						velocity.x = direction * speed
					elif Input.is_action_pressed("d") and direction == 1:
						velocity.x = direction * speed
					else:
						velocity.x = 0
					
					if Input.is_action_just_pressed("w"):
						$SpikeArea/CollisionShape3D.disabled = false
						velocity.y = 20
						velocity.x = 0
						jumping = true
						$Sprite3D.flip_h = false
				
				if Input.is_action_just_pressed("w") and jumping == true:
					$SpikeArea/CollisionShape3D.disabled = false
			else:
				$Sprite3D.flip_h = false
			
			#Handles whether the player is controlling the spiker
			if Global.player_status == 1:
				processing = true
			else:
				processing = false
			
			#Gravity
			velocity.y -= gravity
			
			animation()
			move_and_slide()
		else:
			$Sprite3D.flip_h = false
			if Input.is_action_just_pressed("a"):
				direction = -1
			elif Input.is_action_just_pressed("d"):
				direction = 1
			elif Input.is_action_just_released("a") and Input.is_action_pressed("d"):
				direction = 1
			elif Input.is_action_just_released("d") and Input.is_action_pressed("a"):
				direction = -1
	else:
		velocity.x = 0
		#Gravity
		velocity.y -= gravity
		spike_finish = false
		if jumping and is_on_floor() or Global.net_side == 1:
			jumping = false
			$SpikeArea/CollisionShape3D.disabled = true
			Global.player_status = 0
		move_and_slide()
	animation()

func animation():
	if processing:
		if jumping == true:
			if Global.spike_pause and Global.net_side == -1:
				$AnimationPlayer.play("Spike")
			elif velocity.y > -5 and is_on_floor():
				$AnimationPlayer.play("Jump")
			elif velocity.y <= 0 and not is_on_floor():
				$AnimationPlayer.play("Fall")
			else:
				return
		elif abs(velocity.x) > 2:
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("Idle")
	else:
		if spike_finish and not is_on_floor():
			$AnimationPlayer.play("SpikeFinish")
		elif not is_on_floor():
			$AnimationPlayer.play("Fall")
		else:
			$AnimationPlayer.play("Idle")
		

func successful_spike():
	if spike_finish == false:
		spike_finish = true
		$SpikeFinishTimer.start()


func _on_spike_finish_timer_timeout() -> void:
	spike_finish = false

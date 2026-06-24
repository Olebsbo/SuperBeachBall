extends CharacterBody3D
@export var speed = 15
var direction = 0
var gravity = 1
var controlling = true
var receiving = false

func _ready() -> void:
	$ReceiveArea/CollisionShape3D.disabled = true

func _physics_process(_delta: float) -> void:
	if Global.point_won == false:
		if Global.receive_pause == false and Global.spike_pause == false:
			#movement
			if Global.player_status == 0:
				controlling = true
				if Input.is_action_just_pressed("a"):
					direction = -1
				elif Input.is_action_just_pressed("d"):
					direction = 1
				elif Input.is_action_just_released("a") and Input.is_action_pressed("d"):
					direction = 1
				elif Input.is_action_just_released("d") and Input.is_action_pressed("a"):
					direction = -1
				
				if Input.is_action_pressed("a") and direction == -1:
					velocity.x = direction * speed
					$Sprite3D.flip_h = true
				elif Input.is_action_pressed("d") and direction == 1:
					velocity.x = direction * speed
					$Sprite3D.flip_h = false
				else:
					velocity.x = 0
					$Sprite3D.flip_h = false
			
				if Input.is_action_just_pressed("w") and receiving == false:
					receiving = true
					$ReceivingTimer.start()
					$ReceiveArea/CollisionShape3D.disabled = false
				
				
				
				#gravity
				velocity.y -= gravity
			else:
				controlling = false
				velocity.x = 0
				$Sprite3D.flip_h = false
			
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
		#gravity
		velocity.y -= gravity
		move_and_slide()
	animation()

func animation():
	if Global.receive_pause:
		if Global.net_side == -1:
			$AnimationPlayer.play("ReceiveBack")
			$Sprite3D.flip_h = false
		else:
			$AnimationPlayer.play("Ready")
	elif Global.spike_pause:
		if Global.net_side == 1:
			$AnimationPlayer.play("Ready")
		else:
			$AnimationPlayer.play("Idle")
	else:
		if controlling:
			if abs(velocity.x) > 2:
				$AnimationPlayer.play("Run")
			else:
				$AnimationPlayer.play("Ready")
		else:
			$AnimationPlayer.play("Idle")





func _on_receiving_timer_timeout() -> void:
	receiving = false
	$ReceiveArea/CollisionShape3D.disabled = true

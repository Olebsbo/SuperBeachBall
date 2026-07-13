extends CharacterBody3D
@export var foot_step : PackedScene
@export var stepped = false

@export var sand_kickback : PackedScene
var spawn_sand_kickback = false

@export var speed = 15
var direction = 0
var gravity = 1
var controlling = true
var receiving = false
var receive_time = 0

func _ready() -> void:
	$ReceiveArea/CollisionShape3D.disabled = true
	$ReceiveArea2/CollisionShape3D.disabled = true
	if Global.red_team_genders == 0:
		var texture = load("res://Sprites/PlayerFemaleEnemy.png")
		$Sprite3D.texture = texture
	else:
		var texture = load("res://Sprites/EnemyMaleReceiver.png")
		$Sprite3D.texture = texture

func _physics_process(_delta: float) -> void:
	if receive_time > 0:
		receive_time -= 1
	elif receive_time == 0:
		receiving = false
		$ReceiveArea/CollisionShape3D.disabled = true
		$ReceiveArea2/CollisionShape3D.disabled = true
	
	$FootstepSound.pitch_scale = randf_range(0.95, 1.05)
	if Global.enemy_status == 0:
		$ControlIndicator.visible = true
	else:
		$ControlIndicator.visible = false
		
	if Global.point_won == false:
		if Global.receive_pause == false and Global.spike_pause == false:
			spawn_sand_kickback = false
			#movement
			if Global.enemy_status == 0:
				controlling = true
				if Input.is_action_just_pressed("left"):
					direction = -1
				elif Input.is_action_just_pressed("right"):
					direction = 1
				elif Input.is_action_just_released("left") and Input.is_action_pressed("right"):
					direction = 1
				elif Input.is_action_just_released("left") and Input.is_action_pressed("right"):
					direction = -1
				
				if Input.is_action_pressed("left") and direction == -1:
					velocity.x = direction * speed
					$Sprite3D.flip_h = true
				elif Input.is_action_pressed("right") and direction == 1:
					velocity.x = direction * speed
					$Sprite3D.flip_h = false
				else:
					velocity.x = 0
					$Sprite3D.flip_h = true
			
				if Input.is_action_just_pressed("up"):
					receive_time = 15
					receiving = true
					$ReceiveArea/CollisionShape3D.disabled = false
					$ReceiveArea2/CollisionShape3D.disabled = false
				
				
				
				#gravity
				velocity.y -= gravity
			else:
				controlling = false
				velocity.x = 0
				$Sprite3D.flip_h = true
			
			move_and_slide()
		else:
			$Sprite3D.flip_h = true
			if Input.is_action_just_pressed("left"):
				direction = -1
			elif Input.is_action_just_pressed("right"):
				direction = 1
			elif Input.is_action_just_released("left") and Input.is_action_pressed("right"):
				direction = 1
			elif Input.is_action_just_released("right") and Input.is_action_pressed("left"):
				direction = -1
		
	else:
		velocity.x = 0
		#gravity
		velocity.y -= gravity
		move_and_slide()
	
	
	#Footstep sand cloud effect
	if stepped:
		stepped = false
		var footstep = foot_step.instantiate()
		get_parent().add_child(footstep)
		footstep.emitting = true
		footstep.global_position = Vector3(global_position.x, global_position.y - 0.7, global_position.z)
		
	animation()
	
func animation():
	if Global.receive_pause:
		if Global.net_side == 1:
			var ball_distance = Global.ball.global_position.x - global_position.x
			if ball_distance < -0.7:
				$AnimationPlayer.play("ReceiveFront")
				if spawn_sand_kickback == false:
					spawn_sand_kickback = true
					var temp = sand_kickback.instantiate()
					get_parent().add_child(temp)
					temp.direction(Global.net_side)
					temp.emitting = true
					temp.global_position = Vector3(global_position.x, global_position.y - 1, global_position.z)
			else:
				$AnimationPlayer.play("ReceiveBack")
				if spawn_sand_kickback == false:
					spawn_sand_kickback = true
					var temp = sand_kickback.instantiate()
					get_parent().add_child(temp)
					temp.direction(Global.net_side)
					temp.emitting = true
					temp.global_position = Vector3(global_position.x, global_position.y - 1, global_position.z)
			$Sprite3D.flip_h = true
		else:
			$AnimationPlayer.play("Ready")
	elif Global.spike_pause:
		if Global.net_side == -1:
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
	pass

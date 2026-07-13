extends CharacterBody3D
@export var foot_step : PackedScene
@export var stepped = false

@export var jump_particles : PackedScene

@export var enemy_receiver : CharacterBody3D
@export var rest_location : Node3D
@export var speed = 10
var jump_height = 20
var spiking = false
var jumping = false
var falling = false
var spike_finish = false
var ball_height : float
var ball_time : float
var ball_x : float
var wait_time = 25

@onready var spike_area = $SpikeArea/CollisionShape3D

func _ready() -> void:
	if Global.red_team_genders == 0:
		var texture = load("res://Sprites/PlayerMaleEnemy.png")
		$Sprite3D.texture = texture
	else:
		var texture = load("res://Sprites/EnemyFemaleSpiker.png")
		$Sprite3D.texture = texture
	


func _physics_process(_delta: float) -> void:
	$FootstepSound.pitch_scale = randf_range(0.95, 1.05)
	
	if Global.enemy_status == 1:
		$ControlIndicator.visible = true
	else:
		$ControlIndicator.visible = false
		
		
	if Global.point_won == false:
		if Global.receive_pause == false and Global.spike_pause == false:
			if spiking:
				#Waits before moving to spike so that ball is in right location
				if wait_time > 0:
					wait_time -= 1
				else:
					if global_position.x > ball_x:
						velocity.x = -speed
					else:
						velocity.x = 0
						if is_on_floor():
							if jumping:
								jumping = false
								spiking = false
								wait_time = 28
							else:
								velocity.y = jump_height
								$SpikeArea/CollisionShape3D.disabled = false
								jumping = true
					
			else:
				var distance = rest_location.global_position.x - global_position.x
				var direction = sign(distance)
				velocity.x = speed * direction
				if abs(distance) < 1:
					velocity.x = 0
			
			velocity.y -= 0.5
			animation()
			move_and_slide()
	else:
		$SpikeArea/CollisionShape3D.disabled = true
		velocity.y -= 0.5
		velocity.x = 0
		move_and_slide()
		
	#Footstep sand cloud effect
	if stepped:
		stepped = false
		var footstep = foot_step.instantiate()
		get_parent().add_child(footstep)
		footstep.emitting = true
		footstep.global_position = Vector3(global_position.x, global_position.y - 0.7, global_position.z)
	
	if falling == true and is_on_floor():
		$JumpSound.playing = true
		falling = false
		var temp = jump_particles.instantiate()
		get_parent().add_child(temp)
		temp.emitting = true
		temp.global_position = Vector3(global_position.x, global_position.y - 1, global_position.z)
	
	if velocity.y < 0 and Global.served:
		falling = true
		
	animation()
			



func animation():
	if Global.enemy_status == 1:
		if jumping == true:
			if Global.spike_pause and Global.net_side == 1:
				$AnimationPlayer.play("Spike")
			elif velocity.y > -5 and is_on_floor():
				$JumpSound.playing = true
				$AnimationPlayer.play("Jump")
				var temp = jump_particles.instantiate()
				get_parent().add_child(temp)
				temp.emitting = true
				temp.global_position = Vector3(global_position.x, global_position.y - 1, global_position.z)
			elif velocity.y <= 0 and not is_on_floor():
				$AnimationPlayer.play("Fall")
			else:
				return
		elif abs(velocity.x) > 2:
			$AnimationPlayer.play("Run")
			if velocity.x > 0:
				$Sprite3D.flip_h = false
			else:
				$Sprite3D.flip_h = true
		else:
			$AnimationPlayer.play("Idle")
	else:
		if Global.spike_pause and Global.net_side == 1:
			$AnimationPlayer.play("Spike")
		elif spike_finish and not is_on_floor():
			$AnimationPlayer.play("SpikeFinish")
		elif not is_on_floor():
			$AnimationPlayer.play("Fall")
		elif abs(velocity.x) > 2:
			$AnimationPlayer.play("Run")
			if velocity.x > 0:
				$Sprite3D.flip_h = false
			else:
				$Sprite3D.flip_h = true
		else:
			$AnimationPlayer.play("Idle")
			$Sprite3D.flip_h = true

func spike():
	spiking = true

func ball_data(i_height, i_vel, time, accel, x_spd, pos):
	ball_time = time * 0.85
	ball_height = i_height + i_vel * ball_time + 0.5 * accel * pow(time, 2)
	var dist = x_spd * ball_time
	var final_location = pos - dist
	ball_x = final_location
	

func successful_spike():
	if spike_finish == false:
		spike_area.disabled = true
		spike_finish = true
		$SpikeFinishTimer.start()
		Global.enemy_status = 0


func _on_spike_finish_timer_timeout() -> void:
	spike_finish = false

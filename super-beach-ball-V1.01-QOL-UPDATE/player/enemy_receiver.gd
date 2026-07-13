extends CharacterBody3D
@export var foot_step : PackedScene
@export var stepped = false

@export var sand_kickback : PackedScene
var spawn_sand_kickback = false

@export var land_zone : Sprite3D
@export var enemy_spiker : CharacterBody3D
@export var speed = 15

@onready var at_landzone_timer: Timer = $AtLandzoneTimer

var received = false
var receive_confirmed = false
var landzone_timer_lock = false


func _ready() -> void:
	if Global.red_team_genders == 0:
		var texture = load("res://Sprites/PlayerFemaleEnemy.png")
		$Sprite3D.texture = texture
	else:
		var texture = load("res://Sprites/EnemyMaleReceiver.png")
		$Sprite3D.texture = texture
	
	if Global.ai_level == 1:
		at_landzone_timer.wait_time = 0.1
	elif Global.ai_level == 2:
		at_landzone_timer.wait_time = 0.05
	else:
		at_landzone_timer.wait_time = 0.01

func _physics_process(_delta: float) -> void:
	$FootstepSound.pitch_scale = randf_range(0.95, 1.05)
	if Global.enemy_status == 0:
		$ControlIndicator.visible = true
	else:
		$ControlIndicator.visible = false
		
		
	if Global.pvp == false:
		if Global.point_won == false:
			if Global.receive_pause == false and Global.spike_pause == false:
				spawn_sand_kickback = false
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
					if Global.ai_level == 3 or Global.ball.rallies < 2:
						$ReceiveArea/CollisionShape3D.disabled = false
						$ReceiveArea2/CollisionShape3D.disabled = false
					if abs(distance) < 1:
						if landzone_timer_lock == false:
							landzone_timer_lock = true
							at_landzone_timer.start()
						velocity.x = 0
						if receive_confirmed == true:
							receive_confirmed = false
							if Global.ai_level == 1:
								var receive_chance = randi_range(0, 1)
								if receive_chance == 1:
									$ReceiveArea/CollisionShape3D.disabled = false
									$ReceiveArea2/CollisionShape3D.disabled = false
							elif Global.ai_level == 2:
								var receive_chance = randi_range(0, 3)
								if receive_chance != 0:
									$ReceiveArea/CollisionShape3D.disabled = false
									$ReceiveArea2/CollisionShape3D.disabled = false
							elif Global.ai_level == 3:
								$ReceiveArea/CollisionShape3D.disabled = false
								$ReceiveArea2/CollisionShape3D.disabled = false
					
					else:
						if direction == 1:
							$Sprite3D.flip_h = false
						else:
							$Sprite3D.flip_h = true
					
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
					$ReceiveArea2/CollisionShape3D.disabled = false
			
				#gravity
				velocity.y -= 1
			else:
				$Sprite3D.flip_h = true
				landzone_timer_lock = false
				receive_confirmed = false
			move_and_slide()
		else:
			$ReceiveArea/CollisionShape3D.disabled = true
			$ReceiveArea2/CollisionShape3D.disabled = true
			velocity.x = 0
			velocity.y -= 1
			move_and_slide()
		
		
		animation()
	
	#Footstep sand cloud effect
	if stepped:
		stepped = false
		var footstep = foot_step.instantiate()
		get_parent().add_child(footstep)
		footstep.emitting = true
		footstep.global_position = Vector3(global_position.x, global_position.y - 0.7, global_position.z)
		

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
		if abs(velocity.x) > 2:
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("Ready")

#Prevents multiple calculations of receive
func _on_receive_area_body_entered(_body: Node3D) -> void:
	if Global.pvp == false:
		Global.enemy_status = 1
		$ReceiveArea/CollisionShape3D.disabled = true
		$ReceiveArea2/CollisionShape3D.disabled = true
		enemy_spiker.spike()
		received = true
		velocity.x = 0
		

func _on_serve_timer_timeout() -> void:
	$ReceiveArea/CollisionShape3D.disabled = false
	$ReceiveArea2/CollisionShape3D.disabled = false


func _on_at_landzone_timer_timeout() -> void:
	receive_confirmed = true

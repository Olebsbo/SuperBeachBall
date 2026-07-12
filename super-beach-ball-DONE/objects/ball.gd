extends CharacterBody3D
@export var landing_particles : PackedScene
@export var land_zone : Sprite3D
@export var enemy_spiker : CharacterBody3D
@export var player_spiker : CharacterBody3D
@export var camera : Camera3D
var gravity = 0.35
var collision_buffer = 2
var rallies = 0
var spike_strength = 35.0
var rallies_increased = false

func _ready() -> void:
	$FlameParticles.emitting = false
	$FlameParticles.amount = 1

func _physics_process(delta: float) -> void:
	if Global.receive_pause == false and Global.spike_pause == false:
		var collision
		if Global.spiker_movement_testing == false:
			collision = move_and_collide(velocity*delta)
		#Gravity
		if not is_on_floor():
			velocity.y -= gravity
		#Bounce
		if collision:
			collision_buffer -= 1
			if collision_buffer <= 0:
				collision_buffer = 2
				velocity = velocity.bounce(collision.get_normal()) * 0.5
				if abs(velocity.y) > 2:
					camera.shake_rot(0.2, 0.05)
					var pitch = randf_range(0.9, 1.1)
					$BounceSound.pitch_scale = pitch
					$BounceSound.playing = true
					if global_position.y < 1.5:
						var land_particles = landing_particles.instantiate()
						get_parent().add_child(land_particles)
						land_particles.emitting = true
						land_particles.global_position = Vector3(global_position.x, global_position.y - 0.7, global_position.z)
						land_particles.direction(Vector2(velocity.x, velocity.y).normalized(), velocity.length())
				if abs(velocity.y) < 5:
					velocity.y = 0
				if Global.served == true:
					if global_position.y < 1.5 or global_position.x > 11 or global_position.x < -11:
						if Global.point_won == false:
							Global.point_won = true
							if global_position.x > 11.5 or global_position.x < -11.5:
								if Global.hit_out == false:
									Global.hit_out = true
									$StartWhistle.playing = true
							else:
								$EndWhistle.playing = true
		else:
			collision_buffer = 2
		if global_position.x > 11.5 or global_position.x < -11.5:
			if Global.point_won == false:
				$StartWhistle.playing = true
			Global.point_won = true
			Global.hit_out = true
		
				
		#Detects which side of the net the ball is on
		var side_of_net = 0
		if global_position.x < 0:
			side_of_net = -1
			Global.net_side = -1
		else:
			side_of_net = 1
			Global.net_side = 1
		
		#Receive code
		if $ReceiveDetector.get_overlapping_areas() and Global.player_status == 0 and Global.point_won == false:
			receive(side_of_net, delta)
		#Spike code
		elif Input.is_action_just_pressed("w") and $SpikeDetector.get_overlapping_areas() and Global.player_status == 1:
			spike_sounds_play()
			rallies += 1
			rallies_increased = true
			if Global.tutorial:
				Global.spiker_movement_testing = false
			camera.shake_rot(0.4, 0.1)
			Global.last_hit_side = -1
			player_spiker.successful_spike()
			Global.spike_pause = true
			$SpikePauseTimer.start()
			if Input.is_action_pressed("d"):
				velocity = Vector3(33, -15, 0).normalized() * spike_strength
			elif Input.is_action_pressed("a"):
				velocity = Vector3(20, -20, 0).normalized() * spike_strength
			else:
				velocity = Vector3(25, -18, 0).normalized() * spike_strength
			
			#Detect where the ball is going to land by using a really long raycast
			var launch_direction = velocity.normalized()
			launch_direction.x *= 0.8
			$LandingZone.target_position = launch_direction * 4000
			$LandingZone.force_raycast_update()
			if $LandingZone.is_colliding():
				land_zone.land_zone_detected($LandingZone.get_collision_point())
		
		#Enemy receive for if it's an ai
		elif $EnemyReceiveDetector.get_overlapping_areas() and Global.pvp == false:
			if Global.served == false and Global.serving_side == 1 or collision_buffer > 1 and Global.point_won == false:
				receive(side_of_net, delta)
		#Enemy receive if it's a player
		elif $EnemyReceiveDetector.get_overlapping_areas() and Global.enemy_status == 0 and Global.point_won == false and Global.pvp == true:
			receive(side_of_net, delta)
		
		
		#Enemy spike for if it's an ai
		elif $EnemySpikeDetector.get_overlapping_areas() and Global.pvp == false:
			spike_sounds_play()
			rallies += 1
			rallies_increased = true
			if Global.tutorial:
				Global.first_enemy_spike = true
			camera.shake_rot(0.4, 0.1)
			Global.last_hit_side = 1
			var random = randi_range(0, 2)
			Global.spike_pause = true
			$SpikePauseTimer.start()
			if random == 0:
				velocity = Vector3(-29, -15, 0).normalized() * spike_strength
			elif random == 1:
				velocity = Vector3(-27, -18, 0).normalized() * spike_strength
			else:
				velocity = Vector3(-24, -20, 0).normalized() * spike_strength
			#Detect where the ball is going to land by using a really long raycast
			var launch_direction = velocity.normalized()
			launch_direction.x *= 0.8
			$LandingZone.target_position = launch_direction * 4000
			$LandingZone.force_raycast_update()
			if $LandingZone.is_colliding():
				land_zone.land_zone_detected($LandingZone.get_collision_point())
			enemy_spiker.spike_area.disabled = true
			enemy_spiker.successful_spike()
		#Enemy spike for if it's a player
		elif Input.is_action_just_pressed("up") and $EnemySpikeDetector.get_overlapping_areas() and Global.enemy_status == 1 and Global.pvp == true:
			spike_sounds_play()
			rallies += 1
			rallies_increased = true
			camera.shake_rot(0.4, 0.1)
			Global.last_hit_side = 1
			enemy_spiker.successful_spike()
			Global.spike_pause = true
			$SpikePauseTimer.start()
			if Input.is_action_pressed("left"):
				velocity = Vector3(-33, -15, 0).normalized() * spike_strength
			elif Input.is_action_pressed("right"):
				velocity = Vector3(-20, -20, 0).normalized() * spike_strength
			else:
				velocity = Vector3(-25, -18, 0).normalized() * spike_strength
			#Detect where the ball is going to land by using a really long raycast
			var launch_direction = velocity.normalized()
			launch_direction.x *= 0.8
			$LandingZone.target_position = launch_direction * 4000
			$LandingZone.force_raycast_update()
			if $LandingZone.is_colliding():
				land_zone.land_zone_detected($LandingZone.get_collision_point())
		#Continues updating in case ball position is significantly away from the original calculation
		if $LandingZone.is_colliding() and Global.pvp == false:
			land_zone.land_zone_update($LandingZone.get_collision_point())

		
		#Rotation
		$Sprite3D.rotation_degrees.z -= velocity.x * 0.5
		
		
		
		#Increases ball speed after large amount of rallies
		if rallies >= 10 and rallies_increased == true:
			$FlameParticles.emitting = true
			$FlameParticles.amount = min($FlameParticles.amount * 2, 400)
			var g_and_b_color = 1 - (rallies-9.0)/20
			$Sprite3D.modulate = Color(1, g_and_b_color, g_and_b_color)
			spike_strength = rallies - 9 + 35
			rallies_increased = false
	
func receive(side_of_net, delta):
	var pitch = randf_range(0.9, 0.95)
	$ReceiveSound.pitch_scale = pitch
	$ReceiveSound.playing = true
	pitch = randf_range(0.75, 0.8)
	$ReceiveWindSound.pitch_scale = pitch
	$ReceiveWindSound.playing = true
	Global.served = true
	Global.receive_pause = true
	camera.receive_zoom_effect()
	camera.shake_rot(0.4, 0.1)
	$ReceivePauseTimer.start()
	$LandingZone.target_position = Vector3(0, 1, 0)
	if side_of_net == 1 and Global.pvp == false:
		land_zone.update_pos_x = 0
		land_zone.ball_pos_x = 0
	velocity.y = 19
	var distance_x : float
	distance_x = abs(global_position.x - (1 * side_of_net))
	#Parabolic motion
	var a = -0.18
	var b = 19
	var c = 3
	var time = (-b - sqrt(pow(b,2)-(4*a*c)))/(2*a)*delta #Figured out using physics free fall equation, its the time until it reaches the net y level
	var x_speed = distance_x/time
	if side_of_net == 1 and Global.pvp == false:
		enemy_spiker.ball_data(0.7, 22, time, -0.4, x_speed, global_position.x)
	velocity.x = x_speed * side_of_net * -1
	if side_of_net == -1:
		Global.player_status = 1
	elif side_of_net == 1 and Global.pvp == true:
		Global.enemy_status = 1


func _on_receive_pause_timer_timeout() -> void:
	Global.receive_pause = false
	camera.receive_zoom_out()


func _on_spike_pause_timer_timeout() -> void:
	Global.spike_pause = false

func spike_sounds_play():
	var pitch = randf_range(1.35, 1.45)
	$SpikeSound.pitch_scale = pitch
	$SpikeSound.playing = true
	pitch = randf_range(0.75, 0.8)
	$SpikeWindSound.pitch_scale = pitch
	$SpikeWindSound.playing = true

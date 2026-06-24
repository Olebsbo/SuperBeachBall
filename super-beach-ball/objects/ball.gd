extends CharacterBody3D
@export var land_zone : Sprite3D
@export var enemy_spiker : CharacterBody3D
@export var player_spiker : CharacterBody3D
var gravity = 0.4
var collision_buffer = 2



func _physics_process(delta: float) -> void:
	if Global.receive_pause == false and Global.spike_pause == false:
		var collision = move_and_collide(velocity*delta)
		#Gravity
		if not is_on_floor():
			velocity.y -= gravity
		#Bounce
		if collision:
			collision_buffer -= 1 
			if collision_buffer <= 0:
				collision_buffer = 3
				velocity = velocity.bounce(collision.get_normal()) * 0.5
				if abs(velocity.y) < 5:
					velocity.y = 0
				if Global.served == true:
					if global_position.y < 1.5 or global_position.x > 11 or global_position.x < -11:
						Global.point_won = true
						if global_position.x > 11 or global_position.x < -11:
							Global.hit_out = true
		else:
			collision_buffer = 2
		if global_position.x > 11 or global_position.x < -11:
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
		if $ReceiveDetector.get_overlapping_areas() and Global.player_status == 0:
			receive(side_of_net, delta)
		#Spike code
		elif Input.is_action_just_pressed("w") and $SpikeDetector.get_overlapping_areas() and Global.player_status == 1:
			Global.last_hit_side = -1
			var spike_strength = 40
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
		
		#Enemy receive
		elif $EnemyReceiveDetector.get_overlapping_areas() and collision_buffer == 2:
			receive(side_of_net, delta)
		
		#Enemy spike
		elif $EnemySpikeDetector.get_overlapping_areas():
			Global.last_hit_side = 1
			var random = randi_range(0, 2)
			var spike_strength = 40
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
		#Continues updating in case ball position is significantly away from the original calculation
		if $LandingZone.is_colliding():
			land_zone.land_zone_update($LandingZone.get_collision_point())
	
		
		
		
func receive(side_of_net, delta):
	Global.served = true
	Global.receive_pause = true
	$ReceivePauseTimer.start()
	$LandingZone.target_position = Vector3(0, 1, 0)
	if side_of_net == 1:
		land_zone.update_pos_x = 0
		land_zone.ball_pos_x = 0
	velocity.y = 21
	var distance_x : float
	distance_x = abs(global_position.x - (1 * side_of_net))
	#Parabolic motion
	var a = -0.2
	var b = 21
	var c = 3
	var time = (-b - sqrt(pow(b,2)-(4*a*c)))/(2*a)*delta #Figured out using physics free fall equation, its the time until it reaches the net y level
	var x_speed = distance_x/time
	if side_of_net == 1:
		enemy_spiker.ball_data(0.7, 22, time, -0.4, x_speed, global_position.x)
	velocity.x = x_speed * side_of_net * -1
	if side_of_net == -1:
		Global.player_status = 1


func _on_receive_pause_timer_timeout() -> void:
	Global.receive_pause = false


func _on_spike_pause_timer_timeout() -> void:
	Global.spike_pause = false

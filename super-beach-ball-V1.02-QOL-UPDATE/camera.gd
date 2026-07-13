extends Camera3D
@export var ball : CharacterBody3D
@export var UI : CanvasLayer
var cam_pos : Vector2
var receive_zooming = false
var zoom_pos : Vector3
var is_shaking = false

func _ready():
	cam_pos = Vector2(self.global_position.x, self.global_position.y)


func _physics_process(_delta: float) -> void:
	if receive_zooming == false:
		var local_ball_pos = Vector2(ball.global_position.x, ball.global_position.y) - cam_pos
		self.h_offset = lerpf(self.h_offset, clampf(local_ball_pos.x * 0.2, -20, 20), 0.2)
		self.v_offset = lerpf(self.v_offset, clampf(local_ball_pos.y * 0.2, -10, 10), 0.2)
		UI.offset.x = self.h_offset
		UI.offset.y = self.v_offset
	
	
	if receive_zooming:
		fov = lerpf(fov, 50, 0.2)
		var local_zoom_pos_x = zoom_pos.x - self.global_position.x
		var local_zoom_pos_y = zoom_pos.y - self.global_position.y
		self.h_offset = lerpf(self.h_offset, local_zoom_pos_x, 0.15)
		self.v_offset = lerpf(self.v_offset, local_zoom_pos_y, 0.1)
	elif fov < 75:
		fov = lerpf(fov, 75, 0.1)
		if fov > 74.9:
			fov = 75

func receive_zoom_effect():
	receive_zooming = true
	zoom_pos = ball.global_position

func receive_zoom_out():
	receive_zooming = false


func shake_rot(max_rot_deg: float = 2.0, duration : float = 0.25) -> void:
	if is_shaking: return
	is_shaking = true
	
	var max_rot := deg_to_rad(max_rot_deg)
	var time_left := duration
	var start_rotation := rotation
	
	while time_left > 0:
		var offset_x = randf_range(-max_rot, max_rot)
		var offset_y = randf_range(-max_rot, max_rot)
		
		rotation.x = start_rotation.x + offset_x
		rotation.y = start_rotation.y + offset_y
		
		time_left -= get_process_delta_time()
		await get_tree().process_frame
		
	rotation = start_rotation
	is_shaking = false

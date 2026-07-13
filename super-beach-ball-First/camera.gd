extends Camera3D
@export var ball : CharacterBody3D
@export var transition_cover : MeshInstance3D
var cam_pos : Vector2

func _ready():
	cam_pos = Vector2(self.global_position.x, self.global_position.y)


func _physics_process(_delta: float) -> void:
	var local_ball_pos = Vector2(ball.global_position.x, ball.global_position.y) - cam_pos
	self.h_offset = local_ball_pos.x * 0.2
	self.v_offset = local_ball_pos.y * 0.2
	transition_cover.position.x = self.h_offset
	transition_cover.position.y = self.v_offset

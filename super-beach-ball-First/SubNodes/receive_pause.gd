extends Node3D
@export var paused_node : Node
var pause = false

func _physics_process(_delta: float) -> void:
	if pause:
		paused_node.set_physics_process(false)
	else: 
		paused_node.set_physics_process(true)
	
	if Global.receive_pause == true:
		pause = true
	else:
		pause = false

extends OptionButton

func _ready() -> void:
	if Global.particles_on:
		selected = 0
	else:
		selected = 1


func _on_item_selected(index: int) -> void:
	if index == 0:
		Global.particles_on = true
	else:
		Global.particles_on = false

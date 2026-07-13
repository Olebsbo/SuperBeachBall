extends OptionButton

func _ready() -> void:
	selected = Global.ai_level - 1

func _on_item_selected(index: int) -> void:
	var options = [1, 2, 3]
	Global.ai_level = options[index]
	

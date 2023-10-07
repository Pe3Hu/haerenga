extends MarginContainer


@onready var maze = $HBox/Maze
@onready var nexus  = $HBox/Nexus 


func _ready() -> void:
	var input = {}
	input.sketch = self
	maze.set_attributes(input)
	nexus.set_attributes(input)
	
	var core = nexus.cores.get_child(0)
	maze.update_rooms_color_based_on_core_intelligence(core)

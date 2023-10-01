extends MarginContainer


@onready var maze = $HBox/Maze
@onready var nexus  = $HBox/Nexus 


func _ready() -> void:
	var input = {}
	input.sketch = self
	maze.set_attributes(input)
	nexus.set_attributes(input)

extends MarginContainer


@onready var maze = $HBox/Maze


func _ready() -> void:
	var input = {}
	input.sketch = self
	maze.set_attributes(input)

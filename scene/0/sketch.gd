extends MarginContainer


@onready var maze = $HBox/Maze
@onready var nexus  = $HBox/Nexus 


var serifs = []


func _ready() -> void:
	add_serif()
	var input = {}
	input.sketch = self
	maze.set_attributes(input)
	nexus.set_attributes(input)
	
	var core = nexus.cores.get_child(0)
	maze.update_rooms_color_based_on_core_intelligence(core)


func add_serif() -> void:
	var serif = Time.get_unix_time_from_system()
	serifs.append(serif)


func print_serifs() -> void:
	for _i in serifs.size() - 1:
		print([serifs[_i+1] - serifs[_i]])

extends MarginContainer


@onready var cores = $VBox/Cores

var sketch = null
var goal = null


func set_attributes(input_: Dictionary) -> void:
	sketch = input_.sketch
	
	goal = sketch.maze.lairs.get_child(0)
	init_cores()
	
#	var core = cores.get_child(0)
#	core.gameboard.change_resource_stack_value("mineral", 36)
#	core.empowerment["motion"] = 3
#	core.empowerment["acceleration"] = 1.5
#	core.empowerment["extraction"] = 2.4
#	core.empowerment["scan"] = 1.1
#	market.matchmaking(core)


func init_cores() -> void:
	for _i in 1:
		var input = {}
		input.nexus = self
		
		var core = Global.scene.core.instantiate()
		cores.add_child(core)
		core.set_attributes(input)

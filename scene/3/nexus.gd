extends MarginContainer


@onready var cores = $Cores

var sketch = null


func set_attributes(input_: Dictionary) -> void:
	sketch = input_.sketch
	
	init_cores()


func init_cores() -> void:
	for _i in 1:
		var input = {}
		input.nexus = self
		
		var core = Global.scene.core.instantiate()
		cores.add_child(core)
		core.set_attributes(input)

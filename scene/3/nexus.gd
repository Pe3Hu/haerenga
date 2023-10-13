extends MarginContainer


@onready var market = $VBox/Market
@onready var cores = $VBox/Cores

var sketch = null


func set_attributes(input_: Dictionary) -> void:
	sketch = input_.sketch
	
	init_cores()
	var input = {}
	input.nexus = self
	market.set_attributes(input)


func init_cores() -> void:
	for _i in 1:
		var input = {}
		input.nexus = self
		
		var core = Global.scene.core.instantiate()
		cores.add_child(core)
		core.set_attributes(input)

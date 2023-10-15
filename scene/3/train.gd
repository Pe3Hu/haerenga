extends MarginContainer


@onready var vans = $Vans

var core = null
var blueprint = null
var van = null


func set_attributes(input_: Dictionary) -> void:
	core = input_.core
	blueprint = input_.blueprint
	
	init_vans()


func init_vans() -> void:
	for description in blueprint:
		var input = {}
		input.train = self
		input.description = description
	
		var van_ = Global.scene.van.instantiate()
		vans.add_child(van_)
		van_.set_attributes(input)


func active_next_van() -> void:
	if van == null:
		van = vans.get_child(0)
	else:
		van.switch_active()
		var a = vans.get_children()
		var index = (van.get_index() + 1 + vans.get_child_count()) % vans.get_child_count()
		van = vans.get_child(index)
	
	van.switch_active()
	van.apply_tokens()

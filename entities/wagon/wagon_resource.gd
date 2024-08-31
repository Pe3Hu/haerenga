class_name WagonResource extends Resource


var compartment: CompartmentResource:
	set = set_compartment
var active_modules: Array[ModuleResource]

var tween = null
var skip = false #true
var anchor = null
var repeats = 10
var spin_time = 0.40
var spin_gap = 0.25
var display_modules = 3
var repeat_modules = 0
var spin_order: int
var visible_modules: Array[ModuleResource]

const module_size = Vector2(64, 64)


func set_compartment(compartment_: CompartmentResource) -> WagonResource:
	compartment = compartment_
	compartment.train.wagons.append(self)
	active_modules.append_array(compartment.modules)
	return self
	
func roll_module() -> void:
	Global.rng.randomize()
	spin_order = Global.rng.randi_range(0, active_modules.size())
	visible_modules.clear()
	var shifts = [-1, 0, 1]
	
	for shift in shifts:
		var index = (spin_order + shift + active_modules.size() + 1) % active_modules.size()
		var module = active_modules[index]
		visible_modules.append(module)

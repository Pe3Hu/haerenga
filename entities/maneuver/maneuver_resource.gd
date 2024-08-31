class_name ManeuverResource extends Resource


var tactic: TacticResource:
	set = set_tactic
var index: int:
	set = set_index
var orders: Array[int]
var modules: Array[ModuleResource]
var types: Dictionary


func set_index(index_: int) -> ManeuverResource:
	index = index_
	orders.append_array(Global.dict.maneuver.index[index].orders)
	return self
	
func set_tactic(tactic_: TacticResource) -> ManeuverResource:
	tactic = tactic_
	tactic.maneuvers.append(self)
	tactic.deck_indexs.append(index)
	return self
	
func update_modules() -> void:
	types = {}
	
	for _i in orders.size():
		var carousel_resource = tactic.squad.carousels[_i]
		var order = orders[_i]
		var module = carousel_resource.visible_modules[order]
		
		if !types.has(module.type):
			types[module.type] = 0
		
		types[module.type] += module.value
	
	#for type in types:
	for type in Global.arr.module:
		if types.has(type):
			var module_resource = ModuleResource.new()
			module_resource.set_type(type).set_value(types[type])
			modules.append(module_resource)

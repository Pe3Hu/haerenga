class_name CompartmentResource extends Resource


var corporation: CorporationResource:
	set = set_corporation
var part: String:
	set = set_part
var modules: Array[ModuleResource]
var train: TrainResource
var emblem_index: int


func set_part(part_: String) -> CompartmentResource:
	part = part_
	return self
	
func set_corporation(corporation_: CorporationResource) -> CompartmentResource:
	corporation = corporation_
	corporation.compartments.append(self)
	init_modules()
	return self
	
func init_modules() -> void:
	var index = Global.dict.compartment.part[part].pick_random()
	var description = Global.dict.compartment.index[index]
	
	for order in description.modules:
		var module = ModuleResource.new()
		module.set_order(order).set_compartment(self)

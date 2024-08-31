class_name ModuleResource extends Resource


var compartment: CompartmentResource:
	set = set_compartment
var input: SocketResource
var output: SocketResource
var order: int
var index: int


func set_compartment(compartment_: CompartmentResource) -> ModuleResource:
	compartment = compartment_
	compartment.modules.append(self)
	
	index = Global.dict.module.part[compartment.part][order].pick_random()
	var description = Global.dict.module.index[index]
	
	for type in description.sockets:
		input = SocketResource.new()
		input.type = type
		input.subtype = description.sockets[type].type
		input.value = description.sockets[type].value
	
	return self
	
func set_order(order_: int) -> ModuleResource:
	order = order_
	return self
	

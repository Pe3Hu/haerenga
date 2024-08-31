class_name Compartment extends PanelContainer


var train: Train:
	set = set_train
var resource: CompartmentResource:
	set = set_resource


func set_train(train_: Train) -> Compartment:
	train = train_
	train.compartments.add_child(self)
	return self
	
func set_resource(resource_: CompartmentResource) -> Compartment:
	resource = resource_
	return self

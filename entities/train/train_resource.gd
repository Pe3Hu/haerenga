class_name TrainResource extends Resource


var corporation: CorporationResource:
	set = set_corporation
var compartments: Array[CompartmentResource]
var wagons: Array[WagonResource]
var tactic: TacticResource
var rolls = []
var fixed = false

const compartment_count = 3


func set_corporation(corporation_: CorporationResource) -> TrainResource:
	corporation = corporation_
	corporation.trains.append(self)
	init_compartments()
	
	tactic = TacticResource.new()
	tactic.train = self
	return self
	
func init_compartments() -> void:
	for _i in compartment_count:
		var compartment = corporation.compartments.pick_random()
		add_compartment(compartment)
	
func add_compartment(compartment_: CompartmentResource) -> void:
	compartment_.train = self
	compartments.append(compartment_)
	corporation.compartments.erase(compartment_)
	var wagon = WagonResource.new()
	wagon.set_compartment(compartment_)
	
func reset() -> void:
	fixed = false
	rolls = []

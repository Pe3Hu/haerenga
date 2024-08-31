class_name CorporationResource extends Resource


var planet: PlanetResource:
	set = set_planet
var compartments: Array[CompartmentResource]
var trains: Array[TrainResource]


func set_planet(planet_: PlanetResource) -> CorporationResource:
	planet = planet_
	planet.corporations.append(self)
	init_compartments()
	add_train()
	return self
	
func init_compartments() -> void:
	var n = 1
	
	for part in Global.arr.part:
		for _i in n:
			var compartment = CompartmentResource.new()
			compartment.set_part(part).set_corporation(self)
	
func add_train() -> void:
	var train = TrainResource.new()
	train.set_corporation(self)

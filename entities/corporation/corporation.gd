class_name Corporation extends PanelContainer


@export var trains: HBoxContainer

@onready var train_scene = preload("res://entities/train/train.tscn")

var planet: Planet:
	set = set_planet
var resource: CorporationResource:
	set = set_resource


func set_planet(planet_: Planet) -> Corporation:
	planet = planet_
	
	for train_resource in resource.trains:
		var train = train_scene.instantiate()
		train.set_resource(train_resource).set_corporation(self)
	
	return self
	
func set_resource(resource_: CorporationResource) -> Corporation:
	resource = resource_
	return self

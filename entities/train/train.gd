class_name Train extends PanelContainer


@export var wagons: HBoxContainer
@export var tactic: Tactic

@onready var wagon_scene = preload("res://entities/wagon/wagon.tscn")

var corporation: Corporation:
	set = set_corporation
var resource: TrainResource:
	set = set_resource


func set_corporation(corporation_: Corporation) -> Train:
	corporation = corporation_
	corporation.trains.add_child(self)
	init_wagons()
	return self
	
func set_resource(resource_: TrainResource) -> Train:
	resource = resource_
	return self
	
func init_wagons() -> void:
	for wagon_resource in resource.wagons:
		var wagon = wagon_scene.instantiate()
		wagon.set_resource(wagon_resource).set_train(self)
	
	#roll_wagons()
	
func roll_wagons() -> void:
	tactic.resource.fill_hand()
	
	for maneuver in tactic.maneuvers.get_children():
		if tactic.resource.hand_indexs.has(maneuver.resource.index):
			maneuver.visible = true
			
	resource.rolls = []
	
	for wagon in resource.wagons:
		resource.rolls.append(wagon)
	
	for wagon in wagons.get_children():
		wagon.roll()
	
func wagon_stopped(wagon_: PanelContainer) -> void:
	resource.rolls.erase(wagon_.resource)
	
	if resource.rolls.is_empty():
		tactic.update_maneuvers()
	
func update_result() -> void:
	resource.result = 0
	
	for wagon in wagons.get_children():
		resource.result += wagon.get_current_facet_value()
		#if result < wagon.get_current_facet_value():
		#	result = wagon.get_current_facet_value()
	
	#var data = {}
	#data.role = role
	#data.value = result
	#print(data)

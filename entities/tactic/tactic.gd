class_name Tactic extends PanelContainer


@export var train: Train
@export var maneuvers: VBoxContainer

@onready var maneuver_scene = preload("res://entities/maneuver/maneuver.tscn")

var resource: TacticResource


func _ready() -> void:
	#resource = train.resource.tactic
	init_maneuvers()
	
func init_maneuvers() -> void:
	for maneuver_resource in resource.maneuvers:
		var maneuver = maneuver_scene.instantiate()
		maneuver.set_resource(maneuver_resource).set_tactic(self)
	
func update_maneuvers() -> void:
	resource.update_maneuvers()
	
	for maneuver in maneuvers.get_children():
		if resource.hand_indexs.has(maneuver.resource.index):
			maneuver.update_actions()
		else:
			maneuver.visible = false

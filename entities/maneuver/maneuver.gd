class_name Maneuver extends PanelContainer


@export var pattern: TextureRect
@export var modules: HBoxContainer

@onready var module_scene = preload("res://entities/module/module.tscn")

var tactic: Tactic:
	set = set_tactic
var resource: ManeuverResource:
	set = set_resource


func set_resource(resource_: ManeuverResource) -> Maneuver:
	resource = resource_
	return self
	
func set_tactic(tactic_: Tactic) -> Maneuver:
	tactic = tactic_
	pattern.material = ShaderMaterial.new()
	pattern.material.shader = load("res://shaders/maneuver pattern.gdshader")
	pattern.material.set("shader_parameter/index", resource.index) 
	tactic.maneuvers.add_child(self)
	return self

func update_modules() -> void:
	reset()
	
	for module_resource in resource.modules:
		var module = module_scene.instantiate()
		module.set_resource(module_resource).set_maneuver(self)
	
func reset() -> void:
	while modules.get_child_count() > 0:
		var module = modules.get_child(0)
		modules.remove_child(module)
		module.queue_free()

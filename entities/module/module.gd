class_name Module extends TextureRect


@export var stack: Token
@export var cooldown: Token
@export var resource: ModuleResource:
	set = set_resource

var wagon: Wagon:
	set = set_wagon
var maneuver: Maneuver:
	set = set_maneuver


func set_maneuver(maneuver_: Maneuver) -> Module:
	maneuver = maneuver_
	maneuver.modules.add_child(self)
	return self
	
func set_wagon(wagon_: Wagon) -> Module:
	wagon = wagon_
	wagon.modules.add_child(self)
	return self
	
func set_resource(resource_: ModuleResource) -> Module:
	resource = resource_
	#resource_is_changed = resource.changed
	stack.label.text = str(resource.value)
	material = load("res://entities/module/materials/" + resource.type + ".tres")
	texture = load("res://entities/module/images/" + resource.type + ".png")
	return self

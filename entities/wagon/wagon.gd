class_name Wagon extends PanelContainer


@export var compartments: VBoxContainer

@onready var compartment_scene = preload("res://entities/compartment/compartment.tscn")

var train: Train:
	set = set_train
var resource: WagonResource:
	set = set_resource


func set_train(train_: Train) -> Wagon:
	train = train_
	train.wagons.add_child(self)
	
	%BG.custom_minimum_size = Vector2(resource.compartment_size.x, resource.compartment_size.y * resource.display_compartments)
	
	#resource.time = Time.get_unix_time_from_system()
	#resource.anchor = Vector2(0, -resource.compartment_size.y)
	init_compartments()
	#shuffle_compartments()
	reset()
	#skip_animation()
	return self
	
func set_resource(resource_: WagonResource) -> Wagon:
	resource = resource_
	return self
	
func init_compartments() -> void:
	for _j in resource.repeats:
		for compartment_resource in resource.member.compartments:
			var compartment = compartment_scene.instantiate()
			compartment.set_resource(compartment_resource).set_wagon(self)
	
func roll() -> void:
	if !train.resource.fixed:
		if resource.skip:
			#skip_animation()
			spin_end()
		else:
			declare_spin()
	
	reset()
	
func reset() -> void:
	resource.repeat_compartments = resource.repeats * resource.active_compartments.size()
	#shuffle_compartments()
	compartments.position.y = -(resource.repeat_compartments - resource.display_compartments) * resource.compartment_size.y
	
func shuffle_compartments() -> void:
	var temps = []
	
	for compartment in compartments.get_children():
		compartments.remove_child(compartment)
		temps.append(compartment)
	
	temps.shuffle()
	
	for compartment in temps:
		compartments.add_child(compartment)
	
func declare_spin() -> void:
	Global.rng.randomize()
	var spin_time = resource.spin_time +  Global.rng.randf_range(-resource.spin_gap, resource.spin_gap)
	resource.roll_compartment()
	var spin_end_position = Vector2(0, -resource.spin_order * resource.compartment_size.y)
	resource.tween = create_tween()
	resource.tween.tween_property(compartments, "position", spin_end_position, spin_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	resource.tween.tween_callback(spin_end)
	
func spin_end():
	train.wagon_stopped(self)
	
func crush() -> void:
	get_parent().remove_child(self)
	queue_free()

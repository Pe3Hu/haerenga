extends MarginContainer

@onready var boxs = $Boxs
@onready var preparation = $Boxs/Preparation
@onready var roll = $Boxs/Roll
@onready var reserve = $Boxs/Reserve
@onready var active = $Boxs/Active
@onready var discard = $Boxs/Discard

var tribe = null
var chain = {}


func set_attributes(input_: Dictionary) -> void:
	tribe = input_.tribe
	
#	preparation.title.text = "preparation"
#	roll.title.text = "roll"
#	reserve.title.text = "reserve"
#	active.title.text = "active"
#	discard.title.text = "discard"
#
#	chain["Preparation"] = "roll"
#	chain["Roll"] = "reserve"
#	chain["Reserve"] = "active"
#	chain["Active"] = "discard"
#	chain["Discard"] = "preparation"
	preparation.title.text = "preparation"
	active.title.text = "active"
	
	chain["Preparation"] = "active"
	chain["Active"] = "preparation"



func push_dice_in_next_box(dice_) -> void:
	var next_box = get(chain[dice_.box.name])
	dice_.box.dices.remove_child(dice_)
	dice_.box.update_dices_columns()
	next_box.dices.add_child(dice_)
	dice_.box = next_box
	next_box.update_dices_columns()


func select_dices() -> void:
	var dices = []
	dices.append_array(preparation.dices.get_children())
	
	for dice in dices:
		push_dice_in_next_box(dice)
	
	reroll_dices()


func roll_dices() -> void:
	for dice in reserve.dices.get_children():
		push_dice_in_next_box(dice)


func reroll_dices() -> void:
	for dice in roll.dices.get_children():
		dice.skip_animation()
		var facet = dice.get_current_facet()
		
		if !facet.fail:
			push_dice_in_next_box(dice)


func active_dices() -> void:
	for dice in active.dices.get_children():
		dice.apply_outcome()
		push_dice_in_next_box(dice)


func discard_dices() -> void:
	for dice in discard.dices.get_children():
		push_dice_in_next_box(dice)


func all_in_one() -> void:
	for dice in preparation.dices.get_children():
		dice.skip_animation()
		push_dice_in_next_box(dice)
	
	active_dices()


#func reset() -> void:
#	for box in boxs.get_children():
#		box.crush_excess_dices()

class_name TacticResource extends Resource


var train: TrainResource:
	set = set_train
var maneuvers: Array[ManeuverResource]
var deck_indexs: Array[int]
var hand_indexs: Array[int]
var discard_indexs: Array[int]
var hand_size = 4


func set_train(train_: TrainResource) -> void:
	train = train_
	#init_maneuvers()
	
func init_maneuvers() -> void:
	for type in Global.dict.maneuver.type:
		for index in Global.dict.maneuver.type[type]:
			var maneuver = ManeuverResource.new()
			maneuver.set_index(index).set_tactic(self)
	
func update_maneuvers() -> void:
	for maneuver in maneuvers:
		if hand_indexs.has(maneuver.index):
			maneuver.update_actions()
	
func fill_hand() -> void:
	discard_indexs.append_array(hand_indexs)
	hand_indexs.clear()
	
	while hand_indexs.size() < hand_size and (!deck_indexs.is_empty() or !discard_indexs.is_empty()):
		if !deck_indexs.is_empty():
			deck_indexs.append_array(discard_indexs)
			deck_indexs.shuffle()
			discard_indexs.clear()
		
		var index = deck_indexs.pop_back()
		hand_indexs.append(index)

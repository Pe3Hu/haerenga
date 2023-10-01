extends MarginContainer


@onready var rooms = $Rooms
@onready var doors = $Doors

var rings = {}
var shift = false
var complete = false
var equals = {}


func _ready() -> void:
	init_rooms()


func init_rooms() -> void:
	rings.room = []
	rings.type = []
	
	add_room(0, 0)
	add_ring("triple", false)
	add_ring("single", true)
	add_ring("triple", true)
	add_ring("equal", true)
	add_ring("equal", true)
	add_ring("equal", true)
	add_ring("single", true)
	add_ring("equal", true)
	add_ring("single", true)
	add_ring("equal", true)
	add_ring("single", true)
	add_ring("equal", true)
	add_ring("single", true)
#	add_ring("equal", true)
#	add_ring("equal", true)
#	add_ring("single", true)
#	add_ring("single", true)
#	add_ring("equal", true)
#	add_ring("trapeze", true)
#	add_ring("double", true)
	
#		var n = rings.type.size() - 1
#		if rings.type[n] == rings.type[n - 1] and  rings.type[n] == "equal":
#			types.erase("equal")
	while !complete:
		var types = Global.dict.ring.weight.duplicate()

		var type = Global.get_random_key(types)
		add_ring(type, true)

		if Global.num.ring.segment < rings.room.back().size() / 3 - 1:
			complete = true

	update_doors()
	update_size()
	#print(rings.room.back().size() / 3 - 1)


func add_ring(type_: String, only_parent_: bool) -> void:
	var n = rings.room.back().size()
	
	if !only_parent_:
		match type_:
			"triple":
				n *= 3
	else:
		var parents = rings.room.back().size() / 3 - 1
		var childs = null
		
		match type_:
			"triple":
				childs = parents * 3
			"double":
				childs = parents * 2
			"single":
				childs = parents + 1
			"equal":
				childs = parents
				shift = !shift
				
				if rings.type.back() == "equal":
					equals[equals.keys().back()].append(rings.type.size())
				else:
					equals[rings.type.size()] = [rings.type.size()]
			"trapeze":
				if parents % 2 == 1:
					childs = (parents / 2) * 3 + 2
				else:
					return
		
		if Global.num.ring.segment < childs / 3:
			return
		
		n = (childs + 1) * 3
	
	rings.type.append(type_)
	rings.room.append([])
	var segment = n / 3
	var angle = {}
	angle.step = PI * 2 / n
	
	for _j in n:
		angle.current = angle.step * _j - PI / 2
		
		if type_ == "equal":
			var sign = -1
			
			if !shift:
				sign = 0
			
			angle.current += sign * angle.step / 2
			
		add_room(angle.current, segment)
	
	add_doors(type_)


func add_room(angle_: float, segment_: int) -> void:
	var input = {}
	input.maze = self
	
	if rings.room.size() > 0:
		input.ring = rings.room.size() - 1
	else:
		input.ring  = 0
		rings.room.append([])
		rings.type.append(null)
	
	#input.position = size * 0.5
	input.position = Vector2().from_angle(angle_) * Global.num.ring.r * input.ring
	input.order = rings.room[input.ring].size()
	input.backdoor = false

	if input.ring > 1:
		if  input.order % segment_ == 0:
			input.backdoor = true
	
	var room = Global.scene.room.instantiate()
	rooms.add_child(room)
	room.set_attributes(input)


func add_doors(type_: String) -> void:
	var n = rings.room.size() - 1
	var k = 2
	var parents = rings.room[n - 1]
	var childs = rings.room[n]
	var segment = {}
	segment.parent = parents.size() / 3
	segment.child = childs.size() / 3
	var index = {}
	
	for _i in 3:
		#connect backdoor
		var a = parents[_i * segment.parent]
		var b = childs[_i * segment.child]
		connect_rooms(a, b, "backdoor")
	
		#connect lift
		if rings.type[n - 1] == "equal":# and type_ != "triple":
			var indexs = [0, 1]
				
				
			if type_ == "single":
				var m = 0
				
				for equal in equals:
					m += equals[equal].size()
				
				if m % 2 == 0:
					indexs = []
#			var m = segment.child - segment.parent + n + equals.keys().size() + 1
#
#			if type_ != "equal":
#				m += 1
#			else:
#				for equal in equals:
#					m += equals[equal].size()
			
			#if shift:
			#	m += 1
			
			#if equals.keys().size() > 1:
			#	m += equals.keys().size() #equals[equals.keys().back()].size() + 
			
#			if _i == 0:
#				print([n, equals, m, type_])
				
			
			for index_ in indexs:
				segment.elder = rings.room[n - 2].size() / 3
				index.elder = _i * segment.elder
				index.child = _i * segment.child
				
				if index_ % 2 == 0:
					index.elder += segment.elder - 1
					index.child += segment.child - 1
				else:
					segment.elder = rings.room[n - 2].size() / 3
					index.elder += 1
					index.child += 1
			
				a = rings.room[n - 2][index.elder]
				b = childs[index.child]
				connect_rooms(a, b, "lift")
			
		
		#connect segment
		if n == 2:
			for _j in 2:
				index.parent = (_i + _j) * segment.parent % parents.size()
				index.child = _i * segment.child  + 1
				a = parents[index.parent]
				b = childs[index.child]
				connect_rooms(a, b, "floor")
		else:
			for _j in segment.parent - 1:
				index.parent = _i * segment.parent + _j + 1
				a = parents[index.parent]
				
				match type_:
					"single":
							for _k in k:
								index.child = _i * segment.child + _j + _k + 1
								b = childs[index.child]
								connect_rooms(a, b, "letter")
					"double":
						for _k in k:
							index.child =  _i * segment.child + _j * k + _k + 1
							b = childs[index.child]
							connect_rooms(a, b, "letter")
					"triple":
						k = 3
						
						for _k in k:
							index.child =  _i * segment.child + _j * k + _k + 1
							b = childs[index.child]
							connect_rooms(a, b, "letter")
					"trapeze":
						if _j % 2 == 1:
							index.child = _i * segment.child + (_j / 2 + 1) * (k + 1)
							b = childs[index.child]
							connect_rooms(a, b, "letter")
						else:
							for _k in k:
								index.child = _i * segment.child + (_j / 2) * (k + 1) + _k + 1
								b = childs[index.child]
								connect_rooms(a, b, "letter")
					"equal":
						for _k in k:
							index.child = (_i * segment.child + _j + _k) % childs.size()
							
							if shift:
								index.child = (index.child + 1) % childs.size()
							
							b = childs[index.child]
							
							if !b.backdoor:
								connect_rooms(a, b, "letter")
	
	#connect ring
	if n > 2:
		for _i in childs.size():
			var a = childs[_i]
			var b = childs[(_i + 1) % childs.size()]
			
			if !(type_ == "equal" and (a.backdoor or b.backdoor)):
				connect_rooms(a, b, "floor")


func connect_rooms(a_: Polygon2D, b_: Polygon2D, type_: String) -> void:
	if !a_.doors.has(b_):
		var input = {}
		input.maze = self
		input.type = type_
		input.rooms = [a_, b_]
		var door = Global.scene.door.instantiate()
		doors.add_child(door)
		door.set_attributes(input)
	else:
		print("door err", rings.room.size())
		a_.paint_white()
		b_.paint_white()


func update_doors() -> void:
	for room in rooms.get_children():
		for door in room.doors:
			if door.type == "lift":
				for room_door in room.doors:
					if door != null:
						var neighbor_room = room.doors[room_door]
						
						for neighbor_door in neighbor_room.doors:
							var vertexs = [door.get_points(), []]
							
							for vertex in neighbor_door.get_points():
								if !vertexs[0].has(vertex):
									vertexs[1].append(vertex)
							
							if vertexs[1].size() == 2:
								if Global.check_lines_intersection(vertexs):
									door.collapse()
									door = null
									break
	
	return 


func update_size() -> void:
	var corners = {}
	corners.leftop = Vector2(rooms.get_child(0).position)
	corners.rightbot = Vector2()
	
	for room in rooms.get_children():
		corners.leftop.x = min(room.position.x, corners.leftop.x)
		corners.leftop.y = min(room.position.x, corners.leftop.y)
		corners.rightbot.x = max(room.position.x, corners.rightbot.x)
		corners.rightbot.y = max(room.position.x, corners.rightbot.y)
	
	corners.leftop.x -= get("theme_override_constants/margin_left")
	corners.leftop.y -= get("theme_override_constants/margin_top")
	corners.rightbot.x += get("theme_override_constants/margin_right")
	corners.rightbot.y += get("theme_override_constants/margin_bottom")
	
	custom_minimum_size = corners.rightbot - corners.leftop + Vector2.ONE * (Global.num.room.r * 2)# * 2
	doors.position += custom_minimum_size * 0.5
	rooms.position += custom_minimum_size * 0.5


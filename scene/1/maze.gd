extends SubViewportContainer

@onready var subViewport = $SubViewport
@onready var polygons = $SubViewport/Polygons
@onready var rooms = $SubViewport/Polygons/Rooms
@onready var doors = $SubViewport/Polygons/Doors
@onready var outposts = $SubViewport/Polygons/Outposts
@onready var lairs = $SubViewport/Polygons/Lairs
@onready var obstacles = $SubViewport/Polygons/Obstacles
@onready var contents = $SubViewport/Polygons/Obstacles
@onready var icons = $SubViewport/Icons
@onready var iRoom = $SubViewport/Icons/Room
@onready var iDoor = $SubViewport/Icons/Door
@onready var iLength = $SubViewport/Icons/Length
@onready var iTide = $SubViewport/Icons/Tide
@onready var camera = $SubViewport/Camera

var sketch = null
var rings = {}
var shift = false
var complete = false
var sectors = {}
var equals = {}
var corners = {}
var focus = null


func set_attributes(input_: Dictionary) -> void:
	sketch = input_.sketch
	sketch.add_serif()
	
	var input = {}
	input.maze = self
	camera.set_attributes(input)
	init_rooms()
	init_sectors()
	sketch.add_serif()
	set_lair()
	sketch.add_serif()
	init_outposts()
	sketch.add_serif()
	init_room_obstacles_and_contents()
	#init_minimap()


func init_rooms() -> void:
	rings.room = []
	rings.type = []
	
	add_room(0, 0)
	add_ring("triple", false)
	add_ring("single", true)
	add_ring("triple", true) #equal trapeze double
	
	while !complete:
		var types = Global.dict.ring.weight.duplicate()
		var n = rings.type.size() - 1
		if rings.type[n] == rings.type[n - 1] and  rings.type[n] == "equal":
			types.erase("equal")

		var type = Global.get_random_key(types)
		add_ring(type, true)

		if Global.num.ring.segment < rings.room.back().size() / 3 - 1:
			complete = true

	update_doors()
	update_size()


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
			var sign_ = -1
			
			if !shift:
				sign_ = 0
			
			angle.current += sign_ * angle.step / 2
			
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
	input.position = Vector2.from_angle(angle_) * Global.num.ring.r * input.ring
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
			var l = 2
			
			if type_ == "single":
				var m = 0
				
				for equal in equals:
					m += equals[equal].size()
				
				if m % 2 == 0:
					l = 0
			
			for _j in l:
				segment.elder = rings.room[n - 2].size() / 3
				index.elder = _i * segment.elder
				index.child = _i * segment.child
				
				if _j % 2 == 0:
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
				connect_rooms(a, b, "letter")
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
	var intersections = []
	
	for ring in rings.room:
		for room in ring:
			for door in room.doors:
				if door.type == "lift" and door != null:
					for room_door in room.doors:
						if door != null:
							var neighbor_room = room.doors[room_door]
							
							for neighbor_door in neighbor_room.doors:
								if door != null:
									var vertexs = [door.get_points(), []]
									
									for vertex in neighbor_door.get_points():
										if !vertexs[0].has(vertex):
											vertexs[1].append(vertex)
									
									if vertexs[1].size() == 2:
										if Global.check_lines_intersection(vertexs):
											if !door.intersections.has(neighbor_door):
												door.intersections.append(neighbor_door)
											
											if !intersections.has(door):
												intersections.append(door)
	
	for door in intersections:
		var flag = true
		var datas = []
		var data = {}
		data.door = door
		data.begin = door.ring.begin
		datas.append(data)
		
		if !door.intersections.is_empty():
			for intersection in door.intersections:
				if intersection.type == "lift":
					data = {}
					data.door = intersection
					data.begin = intersection.ring.begin
					datas.append(data)
				else:
					flag = false
			
			if !flag:
				pass
				door.collapse()
			else:
				datas.sort_custom(func(a, b): return a.begin > b.begin)
				var door_ = datas.front().door
				
				for intersection in door_.intersections:
					intersection.intersections.erase(self)
				intersections.erase(door_)
				door_.collapse()
				#door_.visible = false
	
	return 


func update_size() -> void:
	corners = {}
	corners.leftop = Vector2(rooms.get_child(0).position)
	corners.rightbot = Vector2()
	
	for room in rooms.get_children():
		corners.leftop.x = min(room.position.x, corners.leftop.x)
		corners.leftop.y = min(room.position.x, corners.leftop.y)
		corners.rightbot.x = max(room.position.x, corners.rightbot.x)
		corners.rightbot.y = max(room.position.x, corners.rightbot.y)
	
	polygons.position += subViewport.size * 0.5# - Vector2(Global.vec.size.number) * 0.5
	camera.maze = self
	camera.zoom += Vector2.ONE * 0.5 


func init_sectors() -> void:
	var datas = {}
	var total = 0
	var sectors_ = {}
	
	for ring in rings.room.size():
		datas[ring] = rings.room[ring]
		total += rings.room[ring].size()
	
	var ring = 0
	
	for _i in Global.num.sectors.primary:
		sectors_[_i] = []
		
		while sectors_[_i].size() + rings.room[ring].size() < total / Global.num.sectors.primary:
			sectors_[_i].append_array(rings.room[ring])
			datas.erase(ring)
			ring += 1
	
	while !datas.keys().is_empty():
		var key = datas.keys().front()
		sectors_[Global.num.sectors.primary - 1].append_array(rings.room[key])
		datas.erase(key)
	
	for sector in Global.num.sectors.final:
		sectors[sector] = []
	
	for sector in Global.num.sectors.primary:
		if sector == 0: 
			sectors[sector].append_array(sectors_[sector])
		elif sector == Global.num.sectors.primary - 1:
			sectors[Global.num.sectors.final - 1].append_array(sectors_[Global.num.sectors.primary - 1])
		else:
			sectors[1].append_array(sectors_[sector])
		
	for sector in sectors:
		for room in sectors[sector]:
			room.set_sector(sector)
	
	for door in doors.get_children():
		door.add_length()


func set_lair() -> void:
	var room = rooms.get_child(0)
	room.add_lair()


func init_outposts() -> void:
	var options = []
	var ring = rings.room.size() - 1
	var remoteness = {}
	var backdoors = []
	
	for room in rings.room[ring]:
		if room.backdoor:
			options.append([])
			backdoors.append(room)
		else:
			var option = options.back()
			option.append(room)
			remoteness[room] = round(subViewport.size.length() / 10)
	
	
	for backdoor in backdoors:
		for room in rings.room[ring]:
			if remoteness.has(room):
				var d = round(room.position.distance_to(backdoor.position) / 10)
				remoteness[room] = min(d, remoteness[room])
	
	for options_ in options:
		var datas = {}
		
		for room in options_:
			datas[room] = remoteness[room]
		
		var room = Global.get_random_key(datas)
		room.add_outpost()


func init_room_obstacles_and_contents() -> void:
	for sector in sectors:
		for room in sectors[sector]:
			if room.outpost == null and room.lair == null:
				var result = Global.get_random_obstacle_and_content(sector)
				room.add_obstacle(result.obstacle)
				room.add_content(result.content)


func focus_on_room(room_: Polygon2D) -> void:
	#focus = room_
	#onfocus()
	camera.focus = room_
	camera.onfocus()


func onfocus() -> void:
	if focus != null:
		set_position(-focus.position)


func init_minimap() -> void:
	var input = {}
	input.maze = self
	var minimap = Global.scene.minimap.instantiate()
	#camera.add_child(minimap)
	minimap.set_attributes(input)


func move_icons(direction_: String) -> void:
	var vector = Vector2()
	
	match direction_:
		"up":
			vector += Vector2(0, -1)
		"right":
			vector += Vector2(1, 0)
		"down":
			vector += Vector2(0, 1)
		"left":
			vector += Vector2(-1, 0)
	
	icons.position += vector * 10


func update_rooms_color_based_on_core_intelligence(core_) -> void:
	for room in rooms.get_children():
		room.update_colors_based_on_core_intelligence(core_)

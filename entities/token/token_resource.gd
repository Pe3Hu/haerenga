class_name TokenResource extends Resource


@export_enum("stack", "cooldown") var type = "stack":
	set = set_type
@export var value: int = 0:
	set = set_value

var member: MemberResource:
	set = set_member


func set_value(value_: int) -> TokenResource:
	value = value_
	return self
	
func set_type(type_: String) -> TokenResource:
	type = type_
	return self
	
func set_member(member_: MemberResource) -> TokenResource:
	member = member_
	member.actions.append(self)
	return self
	

extends MarginContainer


@onready var bg = $BG
@onready var tokens = $Tokens

var train = null
var active = true


func set_attributes(input_: Dictionary) -> void:
	train = input_.train
	init_tokens(input_.description)
	

func init_tokens(description_: Dictionary):
	for subtype in description_:
		var input = {}
		input.proprietor = self
		input.subtype = subtype
		input.value = description_[subtype]
	
		var token = Global.scene.token.instantiate()
		tokens.add_child(token)
		token.set_attributes(input)
	
	var style = StyleBoxFlat.new()
	bg.set("theme_override_styles/panel", style)
	switch_active()


func switch_active() -> void:
	active = !active
	var style = bg.get("theme_override_styles/panel")
	
	match active:
		true:
			style.bg_color = Global.color.van["active"]
		false:
			style.bg_color = Global.color.van["inactive"]


func apply_tokens() -> void:
	for token in tokens.get_children():
		var value = token.stack.get_number()
		train.core.gameboard.change_token_value(token.title.subtype, value)

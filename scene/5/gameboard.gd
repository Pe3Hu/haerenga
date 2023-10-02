extends MarginContainer


@onready var deck = $VBox/Cards/Deck
@onready var discard = $VBox/Cards/Discard
@onready var hand = $VBox/Cards/Hand


func _ready() -> void:
	init_basic_cards()


func init_basic_cards() -> void:
	var cards_description = []
	
	for card_description in cards_description:
		var input = {}
		input.type = card_description.type
		input.title = card_description.title

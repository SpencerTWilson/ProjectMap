extends RichTextLabel
class_name TextOutput

@export var text_speed: float

@onready var letters_displayed: float = get_total_character_count()
var pause_display: bool = false
var awaiting_text: bool = true

func _process(delta):
	#Trickle in the text
	if !pause_display and letters_displayed < get_total_character_count():
		letters_displayed += delta * text_speed
		visible_characters = letters_displayed as int
	#Let them know we are done
	else:
		awaiting_text = true

func _print_text(new_text: String, intstant: bool = false):
	
	if !awaiting_text:
		letters_displayed = get_total_character_count()
	
	awaiting_text = false
	append_text("\n\n%s" % new_text)
	
	if intstant:
		letters_displayed = get_total_character_count()

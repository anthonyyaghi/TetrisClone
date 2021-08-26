extends Node


var interface
var playfield

func _ready():
	interface = $Interface
	playfield = $PlayField
	
	interface.connect("start_game", playfield, "start_new_game")
	playfield.connect("score_change", interface, "set_score")
	playfield.connect("level_change", interface, "set_level")
	playfield.connect("next_change", interface, "set_next")
	playfield.connect("hold_change", interface, "set_hold")
	playfield.connect("new_game", interface, "new_game")

extends Control


signal start_game

const block_icons = ["res://interface/I.png", "res://interface/T.png", 
					"res://interface/L.png", "res://interface/J.png",
					"res://interface/S.png", "res://interface/Z.png",
					"res://interface/O.png"]

var score_text
var level_text
var next_image
var hold_image

func _ready():
	score_text = $SidePanel/Score
	level_text = $SidePanel/Level
	next_image = $SidePanel/NextBlock
	hold_image = $SidePanel/HoldBlock


func set_score(value : int):
	var format_score = ("%06d\n" % value)
	score_text.text = format_score


func set_level(level : int):
	level_text.text = str(level) + "\n"


func set_next(block_id : int):
	next_image.texture = load(block_icons[block_id])


func set_hold(block_id : int):
	hold_image.texture = load(block_icons[block_id])


func new_game():
	next_image.texture = load("res://interface/X.png")
	hold_image.texture = load("res://interface/X.png")
	$CenterContainer/Button.visible = true


func _on_Button_pressed():
	emit_signal("start_game")
	$CenterContainer/Button.visible = false


func _on_BackButton_pressed():
	get_tree().change_scene("res://Menu.tscn")

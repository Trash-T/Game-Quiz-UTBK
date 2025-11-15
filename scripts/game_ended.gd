extends Control

@onready var congrats_label: Label = $congrats_label

# One Winner
@onready var one_winner: Panel = $one_winner
@onready var winner: Label = $one_winner/winner

# Two Winners
@onready var two_winners: HBoxContainer = $two_winners
@onready var winner1_name: Label = $two_winners/winner1/winner1_name
@onready var winner2_name: Label = $two_winners/winner2/winner2_name

# Animation
@onready var transition: AnimationPlayer = $transition


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.game_winner == "1":
		winner.text = Global.player1_name
		one_winner.show()
	elif Global.game_winner == "2":
		winner.text = Global.player2_name
		one_winner.show()
	else:
		congrats_label.text = "IT'S A DRAW! THE WINNERS ARE..."
		winner1_name.text = Global.player1_name
		winner2_name.text = Global.player2_name
		two_winners.show()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

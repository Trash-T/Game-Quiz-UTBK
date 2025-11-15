extends Control

@onready var player1_name_input: LineEdit = $player1_name_input
@onready var player2_name_input: LineEdit = $player2_name_input


func _on_start_battle_pressed() -> void:
	var player1_name = player1_name_input.text.strip_edges()
	var player2_name = player2_name_input.text.strip_edges()
	
	if player1_name == "":
		player1_name = "Player 1"
	if player2_name == "":
		player2_name = "Player 2"
	
	Global.player1_name = player1_name
	Global.player2_name = player2_name
	
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

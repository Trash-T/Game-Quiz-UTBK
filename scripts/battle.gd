extends Control

# Player stats
@export var max_health : int = 100
@export var damage : int = 25
@export var small_damage : int = 15
@export var heal : int = 15

# Player 1
@onready var player1_name: Label = $player1_menu/VBoxContainer/player1_name
@onready var player1_healthbar: ProgressBar = $player1_menu/VBoxContainer/player1_healthbar
@onready var player1_quiz_option: TextureRect = $player1_menu/options/quiz_option
@onready var player1_action_option: Control = $player1_menu/options/action_option
@onready var player1_cant_move: Panel = $player1_menu/options/cant_move
var player1_current_health : int = max_health
var has_player1_answered : bool = false

# Player 2
@onready var player2_name: Label = $player2_menu/VBoxContainer/player2_name
@onready var player2_healthbar: ProgressBar = $player2_menu/VBoxContainer/player2_healthbar
@onready var player2_quiz_option: TextureRect = $player2_menu/options/quiz_option
@onready var player2_action_option: Control = $player2_menu/options/action_option
@onready var player2_cant_move: Panel = $player2_menu/options/cant_move
var player2_current_health : int = 100
var has_player2_answered : bool = false

# Quiz Panel
@onready var quiz_panel: Panel = $quiz_panel
@onready var quiz_timer: Timer = $quiz_panel/quiz_timer
@onready var timer_label: Label = $quiz_panel/timer_label
@onready var question: Label = $quiz_panel/VBoxContainer/question
@onready var option_a: Label = $quiz_panel/VBoxContainer/option_a/Panel/option_a
@onready var option_b: Label = $quiz_panel/VBoxContainer/option_b/Panel/option_b
@onready var option_c: Label = $quiz_panel/VBoxContainer/option_c/Panel/option_c
@onready var option_d: Label = $quiz_panel/VBoxContainer/option_d/Panel/option_d

# Animation
@onready var quiz_animation: AnimationPlayer = $quiz_animation
@onready var player1_animation: AnimationPlayer = $player1_animation
@onready var player2_animation: AnimationPlayer = $player2_animation

# Quiz questions
@export var quiz_questions : QuestionCollection
var shuffled_questions : Array[QuizQuestion]
var index_question : int = 0

# GameState
enum GameState {QUIZ, BATTLE, NEUTRAL}
var state = GameState.NEUTRAL

# Battle
var winner : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Change name as customized
	player1_name.text = Global.player1_name
	player2_name.text = Global.player2_name
	
	# Make questions appear at random times
	shuffled_questions = quiz_questions.question_collection.duplicate()
	shuffled_questions.shuffle()
	
	# Set progress bar value to current HP
	set_health(player1_healthbar, player1_current_health)
	set_health(player2_healthbar, player2_current_health)
	
	# Set player option in their panel to quiz options
	show_quiz_option(player1_quiz_option, player1_action_option, player1_cant_move)
	show_quiz_option(player2_quiz_option, player2_action_option, player2_cant_move)
	
	# Call quiz time announcement
	quiz_time_announcement()


func _process(_delta: float) -> void:
	# Will show timer in quiz panel according to the timer left
	if state == GameState.QUIZ and quiz_timer.is_stopped() == false:
		var time_left = quiz_timer.time_left
		var minute = floor(time_left / 60)
		var second = int(time_left) % 60
		timer_label.text = "%02d:%02d" % [minute, second]


func set_health(progress_bar : ProgressBar, current_health : int):
	progress_bar.value = current_health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [current_health, max_health]


func quiz_time_announcement():
	# Wait for 0.5 second
	await get_tree().create_timer(.5).timeout
	# Play animation
	quiz_animation.play("quiz_time")
	await quiz_animation.animation_finished
	# Wait for 0.5 second
	await get_tree().create_timer(0.5).timeout
	quiz_start() # Start quiz


func quiz_start():
	# Edit question, options, and timer in quiz panel 
	question.text = shuffled_questions[index_question].question
	option_a.text = shuffled_questions[index_question].options[0]
	option_b.text = shuffled_questions[index_question].options[1]
	option_c.text = shuffled_questions[index_question].options[2]
	option_d.text = shuffled_questions[index_question].options[3]
	quiz_timer.wait_time = shuffled_questions[index_question].timer
	
	# Set so that player haven't answered quiz question
	has_player1_answered = false
	has_player2_answered = false
	
	# Show quiz panel
	quiz_animation.play("quiz_panel_appear")
	await quiz_animation.animation_finished
	
	# Change gamestate to quiz and start timer
	state = GameState.QUIZ
	quiz_timer.start()


func load_next_quiz():
	# Set player option in their panel to quiz options 
	show_quiz_option(player1_quiz_option, player1_action_option, player1_cant_move) 
	show_quiz_option(player2_quiz_option, player2_action_option, player2_cant_move)
	
	state = GameState.NEUTRAL
	index_question += 1 # Go to the next index question
	winner = 0 # Winner will bw neither player 1 nor 2
	
	# End the game
	if index_question >= shuffled_questions.size() or player1_current_health == 0 or player2_current_health == 0:
		if player1_current_health == 0 and player2_current_health == 0:
			Global.game_winner = "Draw"
		elif player1_current_health == 0:
			Global.game_winner = "2"
		elif player2_current_health == 0:
			Global.game_winner = "1"
		else:
			if player1_current_health > player2_current_health:
				Global.game_winner = "1"
			elif player1_current_health < player2_current_health:
				Global.game_winner = "2"
			else:
				Global.game_winner = "Draw"
		if get_tree() and is_instance_valid(self):
			await get_tree().create_timer(1).timeout
			if get_tree() and is_instance_valid(self):
				get_tree().change_scene_to_file("res://scenes/game_ended.tscn")
	else:
		quiz_time_announcement()


func _input(event: InputEvent) -> void:
	# Only does this if gamestate is in quiz
	if state == GameState.QUIZ:		
		if has_player1_answered == false: # Will do this if player hasn't answered
			# Check for player 1 input
			if event.is_action_pressed("p1_up"):
				check_answer("A", 1)
			if event.is_action_pressed("p1_left"):
				check_answer("B", 1)
			if event.is_action_pressed("p1_right"):
				check_answer("C", 1)
			if event.is_action_pressed("p1_down"):
				check_answer("D", 1)
		
		if has_player2_answered == false: # Will do this if player hasn't answered
			# Check for player 2 input
			if event.is_action_pressed("p2_up"):
				check_answer("A", 2)
			if event.is_action_pressed("p2_left"):
				check_answer("B", 2)
			if event.is_action_pressed("p2_right"):
				check_answer("C", 2)
			if event.is_action_pressed("p2_down"):
				check_answer("D", 2)


func check_answer(answer : String, player : int):
	if player == 1 and has_player1_answered:
		return
	if player == 2 and has_player2_answered:
		return
	
	# Because player has answered, change has_player_answered to false 
	if player == 1:
		has_player1_answered = true
	else:
		has_player2_answered = true
	
	if winner != 0:
		return
	
	# If player answer the correct answer
	if answer == shuffled_questions[index_question].correct_answer:
		# Change gamestate to battle 
		state = GameState.BATTLE
		winner = player # Set who the winner of this round is
		
		quiz_animation.play("quiz_panel_disappear")
		await  quiz_animation.animation_finished
		
		show_cant_move(player1_quiz_option, player1_action_option, player1_cant_move)
		show_cant_move(player2_quiz_option, player2_action_option, player2_cant_move)

		battle_round() # Start battle round
		return
	
	# If player answer wrong
	if player == 1: # If it's player 1
		show_cant_move(player1_quiz_option, player1_action_option, player1_cant_move)
		await take_damage(player1_healthbar, 1, small_damage)
		await get_tree().create_timer(1.25).timeout
		player1_animation.play("idle")
		
	else: # If it's player 2
		show_cant_move(player2_quiz_option, player2_action_option, player2_cant_move)
		await take_damage(player2_healthbar, 2, small_damage)
		await get_tree().create_timer(1.25).timeout
		player2_animation.play("idle")
	
	# If both has answered but they answer wrong
	if has_player1_answered and has_player2_answered and winner == 0:
		await _on_quiz_timer_timeout()


func take_damage(health_bar : ProgressBar, player : int, damage_taken : int):
	if player == 1:	
		player1_animation.play("damaged")
		# Will change player1's healthbar according to their current health now
		player1_current_health = max(0, player1_current_health - damage_taken)
		set_health(health_bar, player1_current_health)
	elif player == 2:
		player2_animation.play("damaged")
		# Will change player2's healthbar according to their current health now
		player2_current_health = max(0, player2_current_health - damage_taken)
		set_health(health_bar, player2_current_health)


func heal_health(health_bar : ProgressBar, player : int):
	if player == 1:
		# If current health is less than max health
		if player1_current_health < max_health:
			player1_animation.play("heal")
			show_cant_move(player1_quiz_option, player1_action_option, player1_cant_move)
			# Will change player's healthbar according to their current health now
			player1_current_health = min(max_health, player1_current_health + heal)
			set_health(health_bar, player1_current_health)
			await player1_animation.animation_finished
			player1_animation.play("idle")
			await get_tree().create_timer(0.3).timeout
			await load_next_quiz()
		else:
			player1_cant_move.get_node("Label").text = "Your HP is full!"
			show_cant_move(player1_quiz_option, player1_action_option, player1_cant_move)
			await get_tree().create_timer(1).timeout
			show_action_option(player1_quiz_option, player1_action_option, player1_cant_move)
			player1_cant_move.get_node("Label").text = "You can't move in this round!"
	elif player == 2:
		# If current health is less than max health
		if player2_current_health < max_health:
			player2_animation.play("heal")
			show_cant_move(player2_quiz_option, player2_action_option, player2_cant_move)
			# Will change player's healthbar according to their current health now
			player2_current_health = min(max_health, player2_current_health + heal)
			set_health(health_bar, player2_current_health)
			await player2_animation.animation_finished
			player2_animation.play("idle")
			await get_tree().create_timer(0.3).timeout
			await load_next_quiz()
		else:
			player2_cant_move.get_node("Label").text = "Your HP is full!"
			show_cant_move(player2_quiz_option, player2_action_option, player2_cant_move)
			await get_tree().create_timer(1).timeout
			show_action_option(player2_quiz_option, player2_action_option, player2_cant_move)
			player2_cant_move.get_node("Label").text = "You can't move in this round!"


func show_action_option(quiz_option, action_option, cant_move):
	quiz_option.hide()
	action_option.show()
	cant_move.hide()


func show_quiz_option(quiz_option, action_option, cant_move):
	quiz_option.show()
	action_option.hide()
	cant_move.hide()


func show_cant_move(quiz_option, action_option, cant_move):
	quiz_option.hide()
	action_option.hide()
	cant_move.show()


func battle_round():
	if winner == 0:
		return
	state = GameState.NEUTRAL
	quiz_timer.stop()
	# If winner is player 1 (will show action option and cantmove for player2)
	if winner == 1:
		show_action_option(player1_quiz_option, player1_action_option, player1_cant_move)
		show_cant_move(player2_quiz_option, player2_action_option, player2_cant_move)
	# If winner is player 2 (will show action option and cantmove for player1)
	elif winner == 2:
		show_action_option(player2_quiz_option, player2_action_option, player2_cant_move)
		show_cant_move(player1_quiz_option, player1_action_option, player1_cant_move)


func _on_quiz_timer_timeout() -> void:
	quiz_animation.play("quiz_panel_disappear")
	await quiz_animation.animation_finished
	
	# If player 1 doesn't answer anything
	if not has_player1_answered:
		show_cant_move(player1_quiz_option, player1_action_option, player1_cant_move)
		await take_damage(player1_healthbar, 1, small_damage)
		await get_tree().create_timer(1.25).timeout
		player1_animation.play("idle")
	# If player 2 doesn't answer anything
	if not has_player2_answered:
		show_cant_move(player2_quiz_option, player2_action_option, player2_cant_move)
		await take_damage(player2_healthbar, 2, small_damage)
		await get_tree().create_timer(1.25).timeout
		player2_animation.play("idle")

	await get_tree().create_timer(1.5).timeout
	await load_next_quiz()


func _on_player_1_attack_pressed() -> void:
	player1_animation.play("attack")
	show_cant_move(player1_quiz_option, player1_action_option, player1_cant_move)
	take_damage(player2_healthbar, 2, damage)
	await get_tree().create_timer(1.25).timeout
	player2_animation.play("idle")
	player1_animation.play("idle")
	await get_tree().create_timer(1.5).timeout
	await load_next_quiz()


func _on_player_1_heal_pressed() -> void:
	await heal_health(player1_healthbar, 1)


func _on_player_2_attack_pressed() -> void:
	player2_animation.play("attack")
	show_cant_move(player2_quiz_option, player2_action_option, player2_cant_move)
	take_damage(player1_healthbar, 1, damage)
	await get_tree().create_timer(1.25).timeout
	player1_animation.play("idle")
	player2_animation.play("idle")
	await get_tree().create_timer(1.5).timeout
	await load_next_quiz()


func _on_player_2_heal_pressed() -> void:
	await heal_health(player2_healthbar, 2)

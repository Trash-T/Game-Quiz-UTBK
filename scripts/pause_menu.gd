extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	test_esc()

func test_esc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		get_tree().paused = true
		$".".show()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		get_tree().paused = false
		$".".hide()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	$".".hide()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

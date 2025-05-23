extends Control

signal restart_game
signal quit_game

func _ready():
	# Set process mode to always process
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Make the screen initially invisible
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Connect button signals
	$VBoxContainer/RestartButton.connect("pressed", Callable(self, "_on_restart_button_pressed"))
	$VBoxContainer/QuitButton.connect("pressed", Callable(self, "_on_quit_button_pressed"))
	
	# Make buttons explicitly handle input
	$VBoxContainer/RestartButton.mouse_filter = Control.MOUSE_FILTER_STOP
	$VBoxContainer/QuitButton.mouse_filter = Control.MOUSE_FILTER_STOP

func _input(event):
	if visible:
		print("GameOverScreen received input: ", event)
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Check if click is on restart button
			var restart_button = $VBoxContainer/RestartButton
			var restart_rect = restart_button.get_global_rect()
			if restart_rect.has_point(event.position):
				print("Click on restart button detected")
				_on_restart_button_pressed()
				accept_event()
			
			# Check if click is on quit button
			var quit_button = $VBoxContainer/QuitButton
			var quit_rect = quit_button.get_global_rect()
			if quit_rect.has_point(event.position):
				print("Click on quit button detected")
				_on_quit_button_pressed()
				accept_event()

func show_screen():
	print("Showing game over screen")
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$VBoxContainer/RestartButton.grab_focus()

# Update final score to display on game over screen
func update_final_score(score: int):
	var score_label = $VBoxContainer/FinalScoreLabel
	if not is_instance_valid(score_label):
		print("ERROR: FinalScoreLabel not found in game over screen")
		return
		
	score_label.text = "FINAL SCORE: " + str(score)
	
	# Add some visual feedback based on score
	if score >= 500:
		score_label.modulate = Color(1, 0.8, 0, 1) # Gold for high scores
		score_label.text = "AWESOME SCORE: " + str(score) + "!"
	elif score >= 200:
		score_label.modulate = Color(0.8, 0.8, 0.8, 1) # Silver for medium scores
		score_label.text = "GREAT SCORE: " + str(score) + "!"
	else:
		score_label.modulate = Color(0.8, 0.5, 0.2, 1) # Bronze for low scores
	
	# Animate the score label to make it more noticeable - using a more robust approach
	score_label.scale = Vector2(0.5, 0.5)
	
	# Create tween with physics process mode to ensure it runs even when game is paused
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	# Store reference to tween to prevent early garbage collection
	score_label.set_meta("active_tween", tween)
	
	tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _on_restart_button_pressed():
	print("Restart button pressed")
	emit_signal("restart_game")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	print("Quit button pressed")
	emit_signal("quit_game")
	get_tree().quit()

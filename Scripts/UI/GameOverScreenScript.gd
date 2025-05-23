extends Control

func _ready():
	# Set process mode to always process
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Make the screen initially invisible
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Buttons are already connected in the scene file to HUD methods
	# Make buttons explicitly handle input
	if has_node("VBoxContainer/RestartButton"):
		$VBoxContainer/RestartButton.mouse_filter = Control.MOUSE_FILTER_STOP
	if has_node("VBoxContainer/QuitButton"):
		$VBoxContainer/QuitButton.mouse_filter = Control.MOUSE_FILTER_STOP

func show_screen():
	print("Showing game over screen")
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Pause the game but ensure UI still works
	get_tree().paused = true
	
	if has_node("VBoxContainer/RestartButton"):
		$VBoxContainer/RestartButton.grab_focus()

# Update final score to display on game over screen
func update_final_score(score: int):
	if not has_node("VBoxContainer/FinalScoreLabel"):
		print("ERROR: FinalScoreLabel not found in game over screen")
		return
		
	var score_label = $VBoxContainer/FinalScoreLabel
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
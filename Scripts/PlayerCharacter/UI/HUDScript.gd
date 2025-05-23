extends Control

#class name
class_name HUD

# Global variable to track when last notification appeared
var last_notification_time: float = 0

#references variables
@onready var currentStateLabelText = $HBoxContainer/VBoxContainer2/CurrentStateLabelText
@onready var moveSpeedLabelText = $HBoxContainer/VBoxContainer2/MoveSpeedLabelText
@onready var desiredMoveSpeedLabelText = $HBoxContainer/VBoxContainer2/DesiredMoveSpeedLabelText
@onready var velocityLabelText = $HBoxContainer/VBoxContainer2/VelocityLabelText
@onready var nbJumpsAllowedInAirLabelText = $HBoxContainer/VBoxContainer2/NbJumpsInAirLabelText
@onready var nbDashsAllowedLabelText = $HBoxContainer/VBoxContainer2/NbDashsAllowedLabelText
@onready var slideWaitTimeLabelText = $HBoxContainer/VBoxContainer2/SlideWaitTimeLabelText
@onready var dashWaitTimeLabelText = $HBoxContainer/VBoxContainer2/DashWaitTimeLabelText
@onready var knockbackToolWaitTimeLabelText = $HBoxContainer/VBoxContainer2/KnockbackToolWaitTimeLabelText
@onready var grappleToolWaitTimeLabelText = $HBoxContainer/VBoxContainer2/GrappleToolWaitTimeLabelText
@onready var framesPerSecondLabelText = $HBoxContainer/VBoxContainer2/FramesPerSecondLabelText
@onready var speedLinesContainer = $SpeedLinesContrainer
@onready var health_bar = $HealthBar
@onready var game_over_screen = $GameOverScreen
@onready var score_label = $ScoreContainer/ScoreLabel

func _ready():
	# Set process mode to allow UI interaction when the game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	speedLinesContainer.visible = false #the speed lines will only be displayed when the character will dashing
		# Initialize health bar
	if health_bar and health_bar.has_node("Label"):
		health_bar.value = 100
		health_bar.get_node("Label").text = "100 / 100"
	
	# Initialize score display
	if has_node("ScoreContainer/ScoreLabel"):
		score_label = $ScoreContainer/ScoreLabel
		score_label.text = "SCORE: 0"
		print("Score label initialized")
	else:
		print("WARNING: Score label not found in HUD")
	
	# Hide game over screen at start
	if game_over_screen:
		game_over_screen.visible = false
		
		# Make sure buttons are connected
		if game_over_screen.has_node("VBoxContainer/RestartButton"):
			var restart_button = game_over_screen.get_node("VBoxContainer/RestartButton")
			if not restart_button.is_connected("pressed", Callable(self, "_on_restart_button_pressed")):
				restart_button.connect("pressed", Callable(self, "_on_restart_button_pressed"))
				
		if game_over_screen.has_node("VBoxContainer/QuitButton"):
			var quit_button = game_over_screen.get_node("VBoxContainer/QuitButton")
			if not quit_button.is_connected("pressed", Callable(self, "_on_quit_button_pressed")):
				quit_button.connect("pressed", Callable(self, "_on_quit_button_pressed"))
	
	# Hide game over screen at start
	if game_over_screen:
		game_over_screen.visible = false

func displayCurrentState(currentState : int):
	#this function manage the current state displayment
	
	var stateSignification : String 
	
	#set the state name to display according to the parameter value
	if currentState == 0:
		stateSignification = "Idle"
	if currentState == 1:
		stateSignification = "Walking"
	if currentState == 2:
		stateSignification = "Running"
	if currentState == 3:
		stateSignification = "Crouching"
	if currentState == 4:
		stateSignification = "Sliding"
	if currentState == 5:
		stateSignification = "Jumping"
	if currentState == 6:
		stateSignification = "In air"
	if currentState == 7:
		stateSignification = "On wall"
	if currentState == 8:
		stateSignification = "Dashing"
	if currentState == 9:
		stateSignification = "Grappling"
	if currentState == 10:
		stateSignification = "Ground pounding"
		
	currentStateLabelText.set_text(str(stateSignification))
	
func displayMoveSpeed(moveSpeed : float):
	#this function manage the move speed displayment
	moveSpeedLabelText.set_text(str(moveSpeed))
	
func displayDesiredMoveSpeed(desiredMoveSpeed : float):
	#this function manage the desired move speed displayment
	desiredMoveSpeedLabelText.set_text(str(desiredMoveSpeed))
	
func displayVelocity(velocity : float):
	#this function manage the current velocity displayment
	velocityLabelText.set_text(str(velocity))
	
func displayNbJumpsAllowedInAir(nbJumpsAllowedInAir : int):
	#this function manage the nb jumps allowed left displayment
	nbJumpsAllowedInAirLabelText.set_text(str(nbJumpsAllowedInAir))
	
func displayNbDashsAllowed(nbDashsAllowed : int):
	#this function manage the nb dashs allowed left displayment
	nbDashsAllowedLabelText.set_text(str(nbDashsAllowed))
	
func displaySlideWaitTime(slideWaitTime : float):
	slideWaitTimeLabelText.set_text(str(slideWaitTime))
	
func displayDashWaitTime(dashWaitTime : float):
	dashWaitTimeLabelText.set_text(str(dashWaitTime))
	
func displayKnockbackToolWaitTime(timeBefCanUseAgain : float):
	#this function manage the knockback tool time left displayment
	knockbackToolWaitTimeLabelText.set_text(str(timeBefCanUseAgain))
	
func displayGrappleHookToolWaitTime(timeBefCanUseAgain : float):
	#this function manage the grapple hook time left displayment
	grappleToolWaitTimeLabelText.set_text(str(timeBefCanUseAgain))
	
func displaySpeedLines(dashTime):
	#this function manage the speed lignes displayment (only when the character is dashing)
	speedLinesContainer.visible = true 
	#when the dash is finished, hide the speed lines
	await get_tree().create_timer(dashTime).timeout
	speedLinesContainer.visible = false 
	
func _process(_delta):
	#this function manage the frames per second displayment
	if framesPerSecondLabelText and is_instance_valid(framesPerSecondLabelText):
		var fps = Engine.get_frames_per_second()
		framesPerSecondLabelText.text = str(fps)

# Updates the health display with current and max health
func update_health_display(current: int, maximum: int):
	if health_bar:
		# Update progress bar value
		health_bar.value = float(current) / float(maximum) * 100
		# Update text label (if available)
		if health_bar.has_node("Label"):
			health_bar.get_node("Label").text = str(current) + " / " + str(maximum)

# Updates the score display
func update_score_display(new_score: int):
	# Try to find the label again if it wasn't initialized previously
	if not score_label or not is_instance_valid(score_label):
		if has_node("ScoreContainer/ScoreLabel"):
			score_label = $ScoreContainer/ScoreLabel
			print("Score label re-initialized")
		else:
			print("ERROR: Cannot find score label to update")
			return
	
	# Update the score text
	score_label.text = "SCORE: " + str(new_score)
	
	# Optional: Add animation for score change
	score_label.modulate = Color(1, 1, 0.5) # Bright yellow
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(score_label, "modulate", Color(1, 1, 1), 0.5)

# Show a milestone notification when the player reaches a score threshold
func show_milestone_notification(message: String):
	# Check if enough time has passed since the last notification (minimum 3 seconds)
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_notification_time < 3.0:
		print("Skipping notification due to time constraint: " + message)
		return
		
	last_notification_time = current_time
	
	# Check if a notification is already visible - clean up existing ones
	var existing_notifications = get_tree().get_nodes_in_group("milestone_notification")
	for note in existing_notifications:
		note.queue_free()
		
	# Create a notification label
	var milestone_label = Label.new()
	milestone_label.text = message
	milestone_label.add_to_group("milestone_notification") # Add to group for tracking
	
	# Set font explicitly from resource
	var font_res = load("res://Arts/Fonts/Ticketing.ttf")
	if font_res:
		milestone_label.add_theme_font_override("font", font_res)
		
	milestone_label.add_theme_font_size_override("font_size", 28)
	milestone_label.modulate = Color(1, 0.7, 0.3, 1) # Orange-yellow (easier to read than red)
	milestone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Position it in the upper part of the screen (less likely to overlap with other UI)
	milestone_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	milestone_label.position.y += 120 # Move down from the very top
	add_child(milestone_label)
	
	# Add a slight outline for better readability
	milestone_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	milestone_label.add_theme_constant_override("outline_size", 2)
	
	# Animate it
	milestone_label.scale = Vector2(0, 0)
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	# Add a reference to keep the label valid during the animation
	milestone_label.set_meta("active_tween", tween)
	
	# Use strong references to prevent cleanup during animation
	tween.tween_property(milestone_label, "scale", Vector2(1, 1), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_interval(2.0) # Show for 2 seconds
	tween.tween_property(milestone_label, "modulate:a", 0.0, 1.0) # Fade out
	
	# Safer cleanup that checks if the object still exists
	tween.finished.connect(func():
		if is_instance_valid(milestone_label) and milestone_label.is_inside_tree():
			milestone_label.queue_free()
	)

# Shows the game over screen
func show_game_over():
	# Clean up any active milestone notifications first
	var existing_notifications = get_tree().get_nodes_in_group("milestone_notification")
	for note in existing_notifications:
		if is_instance_valid(note):
			note.queue_free()
			
	if game_over_screen and is_instance_valid(game_over_screen):
		# Use the GameOverScreen's dedicated show method if it's using our script
		if game_over_screen.has_method("show_screen"):
			game_over_screen.show_screen()
			
			# Update final score if the method exists
			if game_over_screen.has_method("update_final_score"):
				# Get the player's score
				var players = get_tree().get_nodes_in_group("PlayerCharacter")
				if players.size() > 0 and is_instance_valid(players[0]):
					var player_score = players[0].score
					game_over_screen.update_final_score(player_score)
		else:
			# Fallback to the old method
			game_over_screen.visible = true
			
			# Make the mouse visible and able to interact with UI
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
			# Pause the game but ensure UI still works
			get_tree().paused = true

# Restart game (called from restart button)
func _on_restart_button_pressed():
	print("Restart button pressed")
	
	# Reset mouse mode to captured for FPS controls
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Hide game over screen
	if game_over_screen:
		game_over_screen.visible = false
	
	# Unpause the game
	get_tree().paused = false
	
	# Reload current scene
	get_tree().reload_current_scene()

# Quit game (called from quit button)
func _on_quit_button_pressed():
	print("Quit button pressed")
	
	# Unpause before quitting to ensure clean exit
	get_tree().paused = false
	
	# Quit the game
	get_tree().quit()

# Direct input handling for game over screen buttons
func _input(event):
	if game_over_screen and game_over_screen.visible:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Check if click is on restart button
			if game_over_screen.has_node("VBoxContainer/RestartButton"):
				var restart_button = game_over_screen.get_node("VBoxContainer/RestartButton")
				var rect = restart_button.get_global_rect()
				if rect.has_point(event.position):
					_on_restart_button_pressed()
					accept_event()
					
			# Check if click is on quit button
			if game_over_screen.has_node("VBoxContainer/QuitButton"):
				var quit_button = game_over_screen.get_node("VBoxContainer/QuitButton")
				var rect = quit_button.get_global_rect()
				if rect.has_point(event.position):
					_on_quit_button_pressed()
					accept_event()

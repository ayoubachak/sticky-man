extends Control

#class name
class_name HUD

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

func _ready():
	# Set process mode to allow UI interaction when the game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	speedLinesContainer.visible = false #the speed lines will only be displayed when the character will dashing
	
	# Initialize health bar
	if health_bar and health_bar.has_node("Label"):
		health_bar.value = 100
		health_bar.get_node("Label").text = "100 / 100"
	
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
	framesPerSecondLabelText.set_text(str(Engine.get_frames_per_second()))

# Updates the health display with current and max health
func update_health_display(current: int, maximum: int):
	if health_bar:
		# Update progress bar value
		health_bar.value = float(current) / float(maximum) * 100
		# Update text label (if available)
		if health_bar.has_node("Label"):
			health_bar.get_node("Label").text = str(current) + " / " + str(maximum)

# Shows the game over screen
func show_game_over():
	if game_over_screen:
		# Use the GameOverScreen's dedicated show method if it's using our script
		if game_over_screen.has_method("show_screen"):
			game_over_screen.show_screen()
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

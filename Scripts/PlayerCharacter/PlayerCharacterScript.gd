extends CharacterBody3D

#class name
class_name PlayerCharacter

#states variables
enum states
{
	IDLE, WALK, RUN, CROUCH, SLIDE, JUMP, INAIR, ONWALL, DASH, GRAPPLE
}
var currentState 

#move variables
@export_group("move variables")
var moveSpeed : float
var desiredMoveSpeed : float 
@export var desiredMoveSpeedCurve : Curve
@export var maxSpeed : float 
@export var walkSpeed : float
@export var runSpeed : float
@export var crouchSpeed : float
var slideSpeed : float
@export var slideSpeedAddon : float 
@export var dashSpeed : float 
var moveAcceleration : float
@export var walkAcceleration : float
@export var runAcceleration : float 
@export var crouchAcceleration : float 
var moveDecceleration : float
@export var walkDecceleration : float
@export var runDecceleration : float 
@export var crouchDecceleration : float 
@export var inAirMoveSpeedCurve : Curve

#movement variables
@export_group("movement variables")
var inputDirection : Vector2 
var moveDirection : Vector3 
@export var hitGroundCooldown : float #amount of time the character keep his accumulated speed before losing it (while being on ground)
var hitGroundCooldownRef : float 
var lastFramePosition : Vector3 
var floorAngle #angle of the floor the character is on 
var slopeAngle #angle of the slope the character is on
var canInput : bool 
var collisionInfo
var wasOnFloor : bool

#jump variables
@export_group("jump variables")
@export var jumpHeight : float
@export var jumpTimeToPeak : float
@export var jumpTimeToFall : float
@onready var jumpVelocity : float = (2.0 * jumpHeight) / jumpTimeToPeak
@export var jumpCooldown : float
var jumpCooldownRef : float 
@export var nbJumpsInAirAllowed : int 
var nbJumpsInAirAllowedRef : int 
var canCoyoteJump : bool = true
@export var coyoteJumpCooldown : float
var coyoteJumpCooldownRef : float
var coyoteJumpOn : bool = false
var jumpBuffOn : bool = false

#slide variables
@export_group("slide variables")
@export var slideTime : float
@export var slideTimeRef : float 
var slideVector : Vector2 = Vector2.ZERO #slide direction
var startSlideInAir : bool
@export var timeBeforeCanSlideAgain : float
var timeBeforeCanSlideAgainRef : float 
@export var maxSlopeAngle : float #max angle value where the side time duration is applied

#wall run variables
@export_group("wall run variables")
@export var wallJumpVelocity : float 
var canWallRun : bool

#dash variables
@export_group("dash variables")

#health variables
@export_group("health variables")
@export var max_health: int = 100
var current_health: int
@export var invincibility_time: float = 0.5 # Time player is invincible after being hit
var invincibility_timer: float = 0.0 # Current invincibility time
var is_dead: bool = false

# Score variables
@export_group("score variables")
var score: int = 0
@export var zombie_kill_points: int = 10
@export var elite_zombie_kill_points: int = 30
@export var elite_zombie_threshold: int = 100 # Points needed before elite zombies spawn
@export var spawn_rate_increase_threshold: int = 200 # Points needed before spawn rate increases

@export var dashTime : float
var dashTimeRef : float
@export var nbDashAllowed : int
var nbDashAllowedRef : int
@export var timeBeforeCanDashAgain : float = 0.2
var timeBeforeCanDashAgainRef : float = 0.2
@export var timeBefReloadDash : float
var timeBefReloadDashRef : float
var velocityPreDash : Vector3 

#grapple hook variables
@export_group("grapple hook variables")
var grapHookType : Array[String] = ["Pull", "Swing"]
@export var grapHookMaxDist : float
@export var grapHookSpeed : float
@export var grapHookAccel : float
var anchorPoint : Vector3
@export var distToStopGrappleOnFloor : float
@export var distToStopGrappleIAir : float
@export var timeBeforeCanGrappleAgain : float
var timeBeforeCanGrappleAgainRef : float
@export var grappleLaunchJumpVelocity : float
@export var downDirJump : bool #enable if the character can jump while grappling downhill

#knockback variables
@export_group("Knockback variables")
@export var onFloorKnockbackDivider : float

#gravity variables
@export_group("gravity variables")
@onready var jumpGravity : float = (-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)
@onready var fallGravity : float = (-2.0 * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)
@export var wallGravityMultiplier : float

#references variables
@onready var cameraHolder = $CameraHolder
@onready var camera3d: Camera3D = $CameraHolder/Camera3D
@onready var standHitbox = $standingHitbox
@onready var crouchHitbox = $crouchingHitbox
@onready var ceilingCheck = $Raycasts/CeilingCheck
@onready var floorCheck = $Raycasts/FloorCheck
@onready var grappleHookCheck = $CameraHolder/Camera3D/GrappleHookCheck
@onready var grapHookRope = $CameraHolder/Camera3D/GrappleHookRope
@onready var mesh = $MeshInstance3D
@onready var hud = $HUD
@onready var pauseMenu = $PauseMenu
@export var bullet_scene: PackedScene

func _ready():
	# Add player to group for reference by bullets
	add_to_group("PlayerCharacter")
	
	# Initialize health
	current_health = max_health
	is_dead = false
	
	# Initialize score
	score = 0
	if hud:
		hud.update_score_display(score)
	
	#set the start move speed
	moveSpeed = walkSpeed
	moveAcceleration = walkAcceleration
	moveDecceleration = walkDecceleration
	
	#set the values refenrentials for the needed variables
	desiredMoveSpeed = moveSpeed 
	jumpCooldownRef = jumpCooldown
	nbJumpsInAirAllowedRef = nbJumpsInAirAllowed
	hitGroundCooldownRef = hitGroundCooldown
	coyoteJumpCooldownRef = coyoteJumpCooldown
	slideTimeRef = slideTime
	dashTimeRef = dashTime
	nbDashAllowedRef = nbDashAllowed
	timeBeforeCanSlideAgainRef = timeBeforeCanSlideAgain
	timeBeforeCanDashAgainRef = timeBeforeCanDashAgain
	timeBefReloadDashRef = timeBefReloadDash
	timeBeforeCanGrappleAgainRef = timeBeforeCanGrappleAgain
	canWallRun = false
	canInput = true
	
	#disable the crouch hitbox, enable is standing one
	if !crouchHitbox.disabled: crouchHitbox.disabled = true 
	if standHitbox.disabled: standHitbox.disabled = false
	
	#set the raycasts
	if !ceilingCheck.enabled: ceilingCheck.enabled = true
	if !floorCheck.enabled: floorCheck.enabled = true
	if !grappleHookCheck.enabled: grappleHookCheck.enabled = true
	
	grappleHookCheck.target_position = Vector3(-grapHookMaxDist, 0.0, 0.0) #-grapHookMaxDist pour être bien dans la direction du joueur
	if grapHookRope.visible: grapHookRope.visible = false
	
	#set the mesh scale of the character
	mesh.scale = Vector3(1.0, 1.0, 1.0)
	
func _process(_delta):
	#the behaviours that is preferable to check every "visual" frame
	
	if !pauseMenu.pauseMenuEnabled:
		inputManagement()
		
		displayStats()
	
func _physics_process(delta):
	#the behaviours that is preferable to check every "physics" frame
	
	applies(delta)
	
	move(delta)
	
	grappleHookManagement(delta)
	
	collisionHandling()
	
	# Process damage invincibility
	process_invincibility(delta)
	
	move_and_slide()

func inputManagement():
	#for each state, check the possibles actions available
	#This allow to have a good control of the controller behaviour, because you can easely check the actions possibls, 
	#add or remove some, and it prevent certain actions from being played when they shouldn't be
	
	if canInput:
		match currentState:
			states.IDLE:
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
				
				if Input.is_action_just_pressed("crouch | slide"):
					crouchStateChanges()
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
					
			states.WALK:
				if Input.is_action_just_pressed("run"):
					runStateChanges()
				
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
				
				if Input.is_action_just_pressed("crouch | slide"):
					crouchStateChanges()
				
				if Input.is_action_just_pressed("dash"):
					dashStateChanges()
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
					
			states.RUN:
				if Input.is_action_just_pressed("run"):
					walkStateChanges()
				
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
					
				if Input.is_action_just_pressed("crouch | slide"):
					slideStateChanges()
				
				if Input.is_action_just_pressed("dash"):
					dashStateChanges()
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
					
			states.CROUCH: 
				if Input.is_action_just_pressed("run") and !ceilingCheck.is_colliding():
					walkStateChanges()
				
				if Input.is_action_just_pressed("crouch | slide") and !ceilingCheck.is_colliding(): 
					walkStateChanges()
					
			states.SLIDE: 
				if Input.is_action_just_pressed("run"):
					slideStateChanges()
				
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
				
				if Input.is_action_just_pressed("crouch | slide"):
					slideStateChanges()
					
			states.JUMP:
				if Input.is_action_just_pressed("crouch | slide"):
					slideStateChanges()
					
				if Input.is_action_just_pressed("dash"):
					dashStateChanges()
					
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
					
			states.INAIR: 
				if Input.is_action_just_pressed("crouch | slide"):
					slideStateChanges()
					
				if Input.is_action_just_pressed("dash"):
					dashStateChanges()
					
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
					
			states.ONWALL:
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					
			states.DASH:
				pass 
				
			states.GRAPPLE:
				if Input.is_action_just_pressed("jump"):
					jump(grapHookSpeed/3, true)
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
					
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		shoot()
		
	if Input.is_action_just_pressed("useKnockbackTool") and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		pass # Prevent both grappling hook and knockback tool from activating simultaneously
	
func displayStats():
	#call the functions in charge of displaying the controller properties
	hud.displayCurrentState(currentState)
	hud.displayMoveSpeed(moveSpeed)
	hud.displayDesiredMoveSpeed(desiredMoveSpeed)
	hud.displayVelocity(velocity.length())
	hud.displayNbDashsAllowed(nbDashAllowed)
	hud.displaySlideWaitTime(timeBeforeCanSlideAgain)
	hud.displayDashWaitTime(timeBeforeCanDashAgain)
	hud.displayNbJumpsAllowedInAir(nbJumpsInAirAllowed)
	hud.displayGrappleHookToolWaitTime(timeBeforeCanGrappleAgain)
	
	#not a property, but a visual
	if currentState == states.DASH: hud.displaySpeedLines(dashTime)
	
func applies(delta):
	#general appliements
	
	floorAngle = get_floor_normal() #get the angle of the floor
	
	if !is_on_floor():
		#modify the type of gravity to apply to the character, depending of his velocity (when jumping jump gravity, otherwise fall gravity)
		if velocity.y >= 0.0:
				if currentState != states.GRAPPLE: velocity.y += jumpGravity * delta
				if currentState != states.SLIDE and currentState != states.DASH and currentState != states.GRAPPLE: currentState = states.JUMP
		else: 
			if currentState != states.GRAPPLE: velocity.y += fallGravity * delta
			if currentState != states.SLIDE and currentState != states.DASH and currentState != states.GRAPPLE: currentState = states.INAIR 
			
		if currentState == states.SLIDE:
			if !startSlideInAir: 
				slideTime = -1 #if the character start slide on the grund, and the jump, the slide is canceled
				
		if currentState == states.DASH: velocity.y = 0.0 #set the y axis velocity to 0, to allow the character to not be affected by gravity while dashing
		
		if hitGroundCooldown != hitGroundCooldownRef: hitGroundCooldown = hitGroundCooldownRef #reset the before bunny hopping value
		
		if coyoteJumpCooldown > 0.0: coyoteJumpCooldown -= delta
		
	if is_on_floor():
		slopeAngle = rad_to_deg(acos(floorAngle.dot(Vector3.UP))) #get the angle of the slope 
		
		if currentState == states.SLIDE and startSlideInAir: startSlideInAir = false
		
		if jumpBuffOn: 
			jumpBuffOn = false
			jump(0.0, false)
			
		if hitGroundCooldown >= 0: hitGroundCooldown -= delta #disincremente the value each frame, when it's <= 0, the player lose the speed he accumulated while being in the air 
		
		if nbJumpsInAirAllowed != nbJumpsInAirAllowedRef: nbJumpsInAirAllowed = nbJumpsInAirAllowedRef #set the number of jumps possible
		
		if coyoteJumpCooldown != coyoteJumpCooldownRef: coyoteJumpCooldown = coyoteJumpCooldownRef
		
		#set the move state depending on the move speed, only when the character is moving
		
		#not the best piece of code i made, but i didn't really saw a more efficient way
		if inputDirection != Vector2.ZERO and moveDirection != Vector3.ZERO:
			match moveSpeed:
				crouchSpeed: currentState = states.CROUCH 
				walkSpeed: currentState = states.WALK
				runSpeed: currentState = states.RUN 
				slideSpeed: currentState = states.SLIDE 
				dashSpeed: currentState = states.DASH 
				grapHookSpeed: moveSpeed = runSpeed
		else:
			#set the state to idle
			if currentState == states.JUMP or currentState == states.INAIR or currentState == states.WALK or currentState == states.RUN: 
				if velocity.length() < 1.0: currentState = states.IDLE 
					
	if is_on_wall(): #if the character is on a wall
		#set the state on onwall
		wallrunStateChanges()
		
	if is_on_floor() or !is_on_floor():
		#manage the slide behaviour
		if currentState == states.SLIDE:
			#if character slide on an uphill, cancel slide
			
			#there is a bug here related to the uphill/downhill slide 
			#(simply said, i have to adjust manually the lastFramePosition value in order to make the character slide indefinitely downhill bot not uphill)
			#if you know how to resolve that issue, don't hesitate to make a post about it on the discussions tab of the project's Github repository
			
			if !startSlideInAir and lastFramePosition.y+0.1 < position.y: #don't know why i need to add a +0.1 to lastFramePosition.y, otherwise it breaks the mechanic some times
				slideTime = -1 
				
			if !startSlideInAir and slopeAngle < maxSlopeAngle:
				if slideTime > 0: 
					slideTime -= delta
					
			if slideTime <= 0: 
				timeBeforeCanSlideAgain = timeBeforeCanSlideAgainRef
				#go to crouch state if the ceiling is too low, otherwise go to run state 
				if ceilingCheck.is_colliding(): crouchStateChanges()
				else: runStateChanges()
				
		#manage the dash behaviour
		if currentState == states.DASH:
			if canInput: canInput = false #the character cannot change direction while dashing 
			
			if dashTime > 0: dashTime -= delta
			
			#the character cannot dash anymore, change to corresponding variables, and go back to run state
			if dashTime <= 0: 
				velocity = velocityPreDash #go back to pre dash velocity
				canInput = true 
				timeBeforeCanDashAgain = timeBeforeCanDashAgainRef
				runStateChanges()
				
		if timeBeforeCanSlideAgain > 0.0: timeBeforeCanSlideAgain -= delta 
		
		if timeBeforeCanDashAgain > 0.0: timeBeforeCanDashAgain -= delta
		
		#manage the dash reloading
		if timeBefReloadDash > 0.0 and nbDashAllowed != nbDashAllowedRef: timeBefReloadDash -= delta
		if timeBefReloadDash <= 0.0 and nbDashAllowed != nbDashAllowedRef:
			timeBefReloadDash = timeBefReloadDashRef
			nbDashAllowed += 1
			
		if timeBeforeCanGrappleAgain > 0.0: timeBeforeCanGrappleAgain -= delta
		
		if currentState == states.JUMP: floor_snap_length = 0.0 #the character cannot stick to structures while jumping
			
		if currentState == states.INAIR: floor_snap_length = 2.5 #but he can if he stopped jumping, but he's still in the air
		
		if jumpCooldown > 0.0: jumpCooldown -= delta
		
func move(delta):
	#direction input
	inputDirection = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	
	#get direction input when sliding
	if currentState == states.SLIDE:
		if moveDirection == Vector3.ZERO: #if the character is moving
			moveDirection = (cameraHolder.basis * Vector3(slideVector.x, 0.0, slideVector.y)).normalized() #get move direction at the start of the slide, and stick to it
	
	#get direction input when wall running
	elif currentState == states.ONWALL:
		moveDirection = velocity.normalized() #get character current velocity and apply it as the current move direction, and stick to it
		
	#dash
	elif currentState == states.DASH:
		if moveDirection == Vector3.ZERO: #if the character is moving
			moveDirection = (cameraHolder.basis * Vector3(inputDirection.x, 0.0, inputDirection.y)).normalized() #get move direction at the start of the dash, and stick to it
			
	#all others 
	else:
		#get the move direction depending on the input
		moveDirection = (cameraHolder.basis * Vector3(inputDirection.x, 0.0, inputDirection.y)).normalized()
		
	#move applies when the character is on the floor
	if is_on_floor():
		#if the character is moving
		if moveDirection:
			#apply slide move
			if currentState == states.SLIDE:
				if slopeAngle > maxSlopeAngle: desiredMoveSpeed += 3.0 * delta #increase more significantly desired move speed if the slope is steep enough
				else: desiredMoveSpeed += 2.0 * delta
				
				velocity.x = moveDirection.x * desiredMoveSpeed
				velocity.z = moveDirection.z * desiredMoveSpeed
				
			#apply dash move
			elif currentState == states.DASH:
				velocity.x = moveDirection.x * dashSpeed
				velocity.z = moveDirection.z * dashSpeed 
				
			#apply grapple hook desired move speed incrementation
			elif currentState == states.GRAPPLE:
					if desiredMoveSpeed < maxSpeed: desiredMoveSpeed += grapHookSpeed * delta
					
			#apply smooth move when walking, crouching, running
			else:
				velocity.x = lerp(velocity.x, moveDirection.x * moveSpeed, moveAcceleration * delta)
				velocity.z = lerp(velocity.z, moveDirection.z * moveSpeed, moveAcceleration * delta)
				
				#cancel desired move speed accumulation if the timer is out
				if hitGroundCooldown <= 0: desiredMoveSpeed = velocity.length()
					
		#if the character is not moving
		else:
			#apply smooth stop 
			velocity.x = lerp(velocity.x, 0.0, moveDecceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, moveDecceleration * delta)
			
			#cancel desired move speed accumulation
			desiredMoveSpeed = velocity.length()
			
	#move applies when the character is not on the floor (so if he's in the air)
	if !is_on_floor():
		if moveDirection:
			#apply dash move
			if currentState == states.DASH: 
				velocity.x = moveDirection.x * dashSpeed
				velocity.z = moveDirection.z * dashSpeed 
				
			#apply slide move
			elif currentState == states.SLIDE:
				desiredMoveSpeed += 2.5 * delta
				
				velocity.x = moveDirection.x * desiredMoveSpeed
				velocity.z = moveDirection.z * desiredMoveSpeed
				
			#apply grapple hook desired move speed incrementation
			elif currentState == states.GRAPPLE:
					if desiredMoveSpeed < maxSpeed: desiredMoveSpeed += grapHookSpeed * delta
					
			#apply smooth move when in the air (air control)
			else:
				if desiredMoveSpeed < maxSpeed: desiredMoveSpeed += 1.5 * delta
				
				#here, set the air control amount depending on a custom curve, to select it with precision, depending on the desired move speed
				var contrdDesMoveSpeed : float = desiredMoveSpeedCurve.sample(desiredMoveSpeed/100)
				var contrdInAirMoveSpeed : float = inAirMoveSpeedCurve.sample(desiredMoveSpeed)
			
				velocity.x = lerp(velocity.x, moveDirection.x * contrdDesMoveSpeed, contrdInAirMoveSpeed * delta)
				velocity.z = lerp(velocity.z, moveDirection.z * contrdDesMoveSpeed, contrdInAirMoveSpeed * delta)
				
		else:
			#accumulate desired speed for bunny hopping
			desiredMoveSpeed = velocity.length()
			
	#move applies when the character is on the wall
	if is_on_wall():
		#apply on wall move
		if currentState == states.ONWALL:
			if moveDirection:
				desiredMoveSpeed += 1.0 * delta 
				
				velocity.x = moveDirection.x * desiredMoveSpeed
				velocity.z = moveDirection.z * desiredMoveSpeed
				
	if desiredMoveSpeed >= maxSpeed: desiredMoveSpeed = maxSpeed #set to ensure the character don't exceed the max speed authorized
	
	lastFramePosition = position
	wasOnFloor = !is_on_floor()
			
func jump(jumpBoostValue : float, isJumpBoost : bool): 
	#this function manage the jump behaviour, depending of the different variables and states the character is
	
	var canJump : bool = false #jump condition
	
	#the jump can only be applied if the player character is pulled up
	if currentState == states.GRAPPLE and lastFramePosition.y > position.y and !downDirJump:
		if jumpBoostValue != 0.0: jumpBoostValue = 0.0
		if isJumpBoost: isJumpBoost = false
		grappleStateChanges()
		return 
		
	#on wall jump 
	if is_on_wall() and canWallRun: 
		currentState = states.JUMP
		velocity = get_wall_normal() * wallJumpVelocity #add some knockback in the opposite direction of the wall
		velocity.y = jumpVelocity
		jumpCooldown = jumpCooldownRef
	else:
		#in air jump
		if !is_on_floor():
			if jumpCooldown <= 0:
				#determine if the character are in the conditions for enable coyote jump
				if wasOnFloor and coyoteJumpCooldown > 0.0 and lastFramePosition.y > position.y: coyoteJumpOn = true
				
				#if the character jump from a jumppad, the jump isn't taken into account in the max numbers of jumps allowed, allowing the character to continusly jump as long as it lands on a jumppad
				if (nbJumpsInAirAllowed > 0) or (nbJumpsInAirAllowed <= 0 and isJumpBoost) or (coyoteJumpOn): #also, take into account if the character is coyote jumping
					if !isJumpBoost and !coyoteJumpOn: nbJumpsInAirAllowed -= 1
					jumpCooldown = jumpCooldownRef
					coyoteJumpOn = false
					canJump = true 
		#on floor jump
		else:
			jumpCooldown = jumpCooldownRef
			canJump = true 
			
	#apply jump
	if canJump:
		if isJumpBoost: nbJumpsInAirAllowed = nbJumpsInAirAllowedRef
		currentState = states.JUMP
		velocity.y = jumpVelocity + jumpBoostValue #apply directly jump velocity to y axis velocity, to give the character instant vertical forcez
		canJump = false 
		
func jumpBuffering():
	#if the character is falling, and the floor check raycast is colliding and the jump properties are good, enable jump buffering
	if floorCheck.is_colliding() and lastFramePosition.y > position.y and nbJumpsInAirAllowed <= 0 and jumpCooldown <= 0.0: jumpBuffOn = true
	
func grappleHookManagement(delta : float):
	var distToAnchorPoint : float #distance entre le personnae et le point d'ancrage du grappin
	
	grappleHookMove(delta, distToAnchorPoint)
	
	grappleHookRopeManagement(distToAnchorPoint)
	
func grappleHookMove(delta : float, distToAnchorPoint : float):
	if currentState == states.GRAPPLE:
		moveDirection = global_position.direction_to(anchorPoint) #direction to move on
		distToAnchorPoint = global_position.distance_to(anchorPoint) #distance from anchor point to character
		if moveDirection:
			#apply grapple hook move
			if is_on_floor():
				if distToAnchorPoint > distToStopGrappleIAir: velocity = lerp(velocity, moveDirection * grapHookSpeed, grapHookAccel * delta)
				else: grappleStateChanges()
			if !is_on_floor():
				if distToAnchorPoint > distToStopGrappleOnFloor: velocity = lerp(velocity, moveDirection * grapHookSpeed, grapHookAccel * delta)
				else: grappleStateChanges()
				
func grappleHookRopeManagement(distToAnchorPoint : float):
	#hide the rope
	if currentState != states.GRAPPLE:
		if grapHookRope.visible: grapHookRope.visible = false
		return
		
	else:
		#show the rope at the corresponding point and direction
		if !grapHookRope.visible: grapHookRope.visible = true
		grapHookRope.look_at(anchorPoint)
		distToAnchorPoint = global_position.distance_to(anchorPoint)
		grapHookRope.scale = Vector3(0.07, 0.18, distToAnchorPoint) #change the scale to make the rope take all the direction width
		
		
#theses functions manages the differents changes and appliments the character will go trought when changing his current state
func crouchStateChanges():
	currentState = states.CROUCH
	moveSpeed = crouchSpeed
	moveAcceleration = crouchAcceleration 
	moveDecceleration = crouchDecceleration
	
	standHitbox.disabled = true
	crouchHitbox.disabled = false 
	
	if mesh.scale.y != 0.7:
		mesh.scale.y = 0.7
		mesh.position.y = -0.5
		
func walkStateChanges():
	currentState = states.WALK
	moveSpeed = walkSpeed
	moveAcceleration = walkAcceleration
	moveDecceleration = walkDecceleration
	
	standHitbox.disabled = false 
	crouchHitbox.disabled = true
	
	if mesh.scale.y != 1.0:
		mesh.scale.y = 1.0
		mesh.position.y = 0.0
	
func runStateChanges():
	currentState = states.RUN
	moveSpeed = runSpeed
	moveAcceleration = runAcceleration
	moveDecceleration = runDecceleration
	
	standHitbox.disabled = false 
	crouchHitbox.disabled = true 
	
	if mesh.scale.y != 1.0:
		mesh.scale.y = 1.0
		mesh.position.y = 0.0
	
func slideStateChanges():
	#condition here, the state is changed only if the character is moving (so has an input direction)
	if timeBeforeCanSlideAgain <= 0 and currentState != states.SLIDE:
		currentState = states.SLIDE 
		
		#change the start slide in air variable depending zon where the slide begun
		if !is_on_floor() and slideTime <= 0: startSlideInAir = true
		elif is_on_floor() and lastFramePosition.y >= position.y: #character can slide only on flat or downhill surfaces: 
			desiredMoveSpeed += slideSpeedAddon #slide speed boost when on ground (for balance purpose)
			startSlideInAir = false 
			
		slideTime = slideTimeRef
		moveSpeed = slideSpeed
		if inputDirection != Vector2.ZERO: slideVector = inputDirection 
		else: slideVector = Vector2(0, -1)
		
		standHitbox.disabled = true
		crouchHitbox.disabled = false 
		
		if mesh.scale.y != 0.7:
			mesh.scale.y = 0.7
			mesh.position.y = -0.5
	elif currentState == states.SLIDE:
		slideTime = -1.0
		timeBeforeCanSlideAgain = timeBeforeCanSlideAgainRef
		if ceilingCheck.is_colliding(): crouchStateChanges()
		else: runStateChanges()
		
func dashStateChanges():
	#condition here, the state is changed only if the character is moving (so has an input direction)
	if inputDirection != Vector2.ZERO and timeBeforeCanDashAgain <= 0.0 and nbDashAllowed > 0:
		currentState = states.DASH
		nbDashAllowed -= 1
		moveSpeed = dashSpeed 
		dashTime = dashTimeRef
		velocityPreDash = velocity #save the pre dash velocity, to apply it when the dash is finished (to get back to a normal velocity)
		
		if mesh.scale.y != 1.0:
			mesh.scale.y = 1.0
			mesh.position.y = 0.0
			
func wallrunStateChanges():
	#condition here, the state is changed only if the character speed is greater than the walk speed
	if velocity.length() > walkSpeed and currentState != states.DASH and currentState != states.CROUCH and canWallRun: 
		currentState = states.ONWALL
		velocity.y *= wallGravityMultiplier #gravity value became onwall one
		
		if nbJumpsInAirAllowed != nbJumpsInAirAllowedRef: nbJumpsInAirAllowed = nbJumpsInAirAllowedRef
		
		standHitbox.disabled = false
		crouchHitbox.disabled = true
		
		if mesh.scale.y != 1.0:
			mesh.scale.y = 1.0
			mesh.position.y = 0.0
			
func grappleStateChanges():
	#condition here, the state is changed only if the character isn't already grappling, and the grapple check is colliding
	if grappleHookCheck.is_colliding() and timeBeforeCanGrappleAgain <= 0.0 and currentState != states.GRAPPLE:
		currentState = states.GRAPPLE
		
		if is_on_floor(): velocity.y = grappleLaunchJumpVelocity
		
		timeBeforeCanGrappleAgain = timeBeforeCanGrappleAgainRef
		if nbJumpsInAirAllowed < nbJumpsInAirAllowedRef: nbJumpsInAirAllowed = nbJumpsInAirAllowedRef
		moveSpeed = grapHookSpeed
		
		#get the collision point of the grapple hook raycast check
		anchorPoint = grappleHookCheck.get_collision_point()
		
		
		standHitbox.disabled = false
		crouchHitbox.disabled = true
		
		if mesh.scale.y != 1.0:
			mesh.scale.y = 1.0
			mesh.position.y = 0.0
			
	#the character is already grappling, so cut grapple state, and change to the one corresponding to his velocity
	elif currentState == states.GRAPPLE:
		if !is_on_floor():
			if velocity.y >= 0.0: currentState = states.JUMP
			else: currentState = states.INAIR
			
func collisionHandling():
	#this function handle the collisions, but in this case, only the collision with a wall, to detect if the character can wallrun
	if is_on_wall():
		var lastCollision = get_slide_collision(0)
		
		if lastCollision:
			var collidedBody = lastCollision.get_collider()
			if collidedBody and is_instance_valid(collidedBody):
				var layer = collidedBody.collision_layer
				
				#here, we check the layer of the collider, then we check if the layer 3 (walkableWall) is enabled, with 1 << 3-1. If theses two points are valid, the character can wallrun
				if layer & (1 << 3-1) != 0: canWallRun = true 
				else: canWallRun = false
			else:
				# Invalid collider, can't wall run
				canWallRun = false
		else:
			# No collision info, can't wall run
			canWallRun = false
			
func _on_object_tool_send_knockback(knockbackAmount : float, knockbackOrientation : Vector3):
	#this function handle the knockback mechanic
	var knockbackForce = -knockbackOrientation * knockbackAmount #opposite of the knockback tool orientation, times knockback amount
	velocity += knockbackForce if !is_on_floor() else knockbackForce/onFloorKnockbackDivider
	
	
func shoot():
	var b = bullet_scene.instantiate()
	print("Creating bullet from: ", bullet_scene.resource_path)

	# Calculate bullet transform based on camera
	var bullet_transform = camera3d.global_transform
	# Offset spawn point a bit forward
	bullet_transform.origin += -bullet_transform.basis.z.normalized() * 2.0

	# Apply full transform to the bullet
	b.global_transform = bullet_transform
	
	# Add bullet to the game
	get_tree().get_root().add_child(b)

# Handle player damage
func take_damage(amount: int) -> void:
	# Check if player is currently invincible
	if invincibility_timer > 0:
		return
		
	# Apply damage
	current_health -= amount
	if current_health < 0:
		current_health = 0
	
	# Update HUD
	if hud:
		hud.update_health_display(current_health, max_health)
	
	# Start invincibility timer
	invincibility_timer = invincibility_time
	
	# Flash the player red when hit
	mesh.material_override = StandardMaterial3D.new()
	mesh.material_override.albedo_color = Color(1, 0.3, 0.3, 1)
	get_tree().create_timer(0.15).timeout.connect(func(): 
		mesh.material_override = null
	)
	
	# Check if player is dead
	if current_health <= 0:
		die()

# Process damage invincibility timer
func process_invincibility(delta: float) -> void:
	if invincibility_timer > 0:
		invincibility_timer -= delta

# Handle player death
func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	print("Player died")
	
	# Disable player input
	canInput = false
	
	# Show game over screen
	if hud:
		hud.show_game_over()
	
	# Optional: play death animation or effects
	mesh.material_override = StandardMaterial3D.new()
	mesh.material_override.albedo_color = Color(0.5, 0.5, 0.5, 1)

# Add points to player's score
func add_score(points: int) -> void:
	var old_score = score
	score += points
	print("Score increased by ", points, ". New score: ", score)
	
	# Update HUD
	if hud:
		hud.update_score_display(score)
	
	# Check if we've reached thresholds for zombie difficulty
	if old_score < elite_zombie_threshold && score >= elite_zombie_threshold:
		print("Elite zombies unlocked!")
		if hud:
			hud.show_milestone_notification("WARNING: Elite Zombies Incoming!")
		
	if old_score < spawn_rate_increase_threshold && score >= spawn_rate_increase_threshold:
		print("Spawn rate increased!")
		if hud:
			hud.show_milestone_notification("DANGER: Zombie Outbreak Intensifying!")
	
	# Create additional milestones every 500 points
	# Use floor division by converting to int
	if floor(old_score / 500.0) < floor(score / 500.0):
		var milestone = floor(score / 500.0) * 500
		if hud:
			hud.show_milestone_notification("Score Milestone: " + str(milestone) + "!")
			
			# Could add gameplay effects here, like temporary invincibility or health boost
			current_health = min(current_health + 20, max_health) # Bonus health at milestones
			hud.update_health_display(current_health, max_health)

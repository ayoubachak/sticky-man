extends CharacterBody3D

@export var max_health: int = 100
var current_health: int
@export var speed: float = 5.0
@export var attack_damage: int = 10    # Damage per hit
@export var attack_interval: float = 2.0 # Time between attacks
var attack_timer: float = 0.0 # Current attack timer

@onready var label: Label3D = $Label3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
var player: Node3D = null
var hit_material: StandardMaterial3D

func _ready() -> void:
	# Add this zombie to the "Zombie" group for bullet collision detection
	add_to_group("Zombie")
	
	current_health = max_health
	label.text = str(current_health)
	
	# Create a material for hit effects
	hit_material = StandardMaterial3D.new()
	hit_material.albedo_color = Color(1, 1, 1, 1)
	if mesh_instance:
		mesh_instance.set_surface_override_material(0, hit_material)
	
	# find the player by group since the scene root is not a Node
	var players = get_tree().get_nodes_in_group("PlayerCharacter")
	if players.size() > 0:
		player = players[0]

func _physics_process(_delta: float) -> void:
	# apply default 3D gravity
	var gravity_val = ProjectSettings.get_setting("physics/3d/default_gravity") as float
	velocity.y -= gravity_val * _delta

	if player:
		# chase on horizontal plane without touching vertical velocity
		var dir = player.global_transform.origin - global_transform.origin
		dir.y = 0
		
		# Check if close enough to attack
		var distance_to_player = dir.length()
		
		if distance_to_player > 0:
			dir = dir.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			
		# Handle attack timer and attack if close enough
		if attack_timer > 0:
			attack_timer -= _delta
		
		# If we're close to player and attack timer is ready, attack
		if distance_to_player < 2.0 and attack_timer <= 0:
			attack_player()
			attack_timer = attack_interval

	move_and_slide()

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health < 0:
		current_health = 0
	
	# Update health display
	label.text = str(current_health)
	
	# Flash the zombie red when hit using the prepared material
	if hit_material:
		hit_material.albedo_color = Color(1, 0.3, 0.3, 1)
		get_tree().create_timer(0.15).timeout.connect(func(): 
			hit_material.albedo_color = Color(1, 1, 1, 1)
		)
	
	# Check if zombie is dead
	if current_health <= 0:
		# Play death effect using the prepared material
		if hit_material:
			hit_material.albedo_color = Color(0.5, 0.5, 0.5, 1)		# Schedule deletion after a short delay for visual feedback
		get_tree().create_timer(0.3).timeout.connect(func(): queue_free())
		
# Attack the player character
func attack_player() -> void:
	if player and player.has_method("take_damage"):
		print("Zombie attacking player with damage: ", attack_damage)
		player.take_damage(attack_damage)
		
		# Visual feedback for attack
		if hit_material:
			hit_material.albedo_color = Color(1, 0.7, 0, 1) # Orange for attack
			get_tree().create_timer(0.2).timeout.connect(func(): 
				hit_material.albedo_color = Color(1, 1, 1, 1)
			)

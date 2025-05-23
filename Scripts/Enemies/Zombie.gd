extends CharacterBody3D

@export var max_health: int = 100
var current_health: int
@export var speed: float = 5.0
@export var attack_damage: int = 10    # Damage per hit
@export var attack_interval: float = 2.0 # Time between attacks
var attack_timer: float = 0.0 # Current attack timer
@export var is_elite_zombie: bool = false # Whether this is an elite zombie

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
	
	# Set appropriate color based on zombie type
	if is_elite_zombie:
		hit_material.albedo_color = Color(0.8, 0.1, 0.1, 1.0) # Red for elite
		# Make the elite zombie slightly larger for better visibility
		if mesh_instance:
			mesh_instance.scale = Vector3(1.2, 1.2, 1.2)
		# Make the elite zombie health label red
		if label:
			label.modulate = Color(0.8, 0.1, 0.1, 1.0)
			label.outline_modulate = Color(1, 1, 1, 1) # White outline for contrast
			label.outline_size = 2
	else:
		hit_material.albedo_color = Color(1, 1, 1, 1) # White for regular zombies
	
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
		# Calculate full 3D distance to player for attack range check
		var full_dir = player.global_transform.origin - global_transform.origin
		var full_distance_to_player = full_dir.length()
		
		# chase on horizontal plane without touching vertical velocity
		var horizontal_dir = full_dir
		horizontal_dir.y = 0
		var horizontal_distance = horizontal_dir.length()
		
		if horizontal_distance > 0:
			horizontal_dir = horizontal_dir.normalized()
			velocity.x = horizontal_dir.x * speed
			velocity.z = horizontal_dir.z * speed
			
		# Handle attack timer and attack if close enough
		if attack_timer > 0:
			attack_timer -= _delta
		
		# If we're close to player (3D distance) and attack timer is ready, attack
		if full_distance_to_player < 2.0 and attack_timer <= 0:
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
		# Award score points to player
		var players = get_tree().get_nodes_in_group("PlayerCharacter")
		if players.size() > 0:
			var player_char = players[0]
			# Check zombie type (regular or elite)
			var points = player_char.elite_zombie_kill_points if is_elite_zombie else player_char.zombie_kill_points
			player_char.add_score(points)
		
		# Play death effect using the prepared material
		if hit_material:
			hit_material.albedo_color = Color(0.5, 0.5, 0.5, 1)
		# Schedule deletion after a short delay for visual feedback
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

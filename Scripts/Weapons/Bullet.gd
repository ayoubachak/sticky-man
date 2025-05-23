extends Area3D

@export var speed: float = 50.0
@export var damage: int = 25
@export var lifetime: float = 3.0  # Maximum bullet lifetime in seconds
@export var hit_effect_duration: float = 0.1  # How long hit effects last

# New weapon system properties
var piercing: bool = false
var energy_damage: bool = false
var explosion_radius: float = 0.0
var hits_count: int = 0
var max_piercing_hits: int = 3

var travel_distance: float = 0.0
var max_distance: float = 1000.0
var material: StandardMaterial3D

# Weapon system methods
func set_damage(new_damage: int):
	damage = new_damage

func set_speed(new_speed: float):
	speed = new_speed

func set_piercing(is_piercing: bool):
	piercing = is_piercing

func set_energy_damage(is_energy: bool):
	energy_damage = is_energy

func set_explosion_radius(radius: float):
	explosion_radius = radius

# Set a higher default speed for better visibility
func _init():
	speed = 100.0  # Double the default speed to make bullets easier to see

func _ready() -> void:
	# Connect the body_entered signal for collision detection
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Add a debug print to verify bullet creation and position
	print("Bullet created at position: ", global_position)
	print("Bullet transform: ", global_transform)
	print("Bullet forward direction will be: ", -global_transform.basis.z.normalized())
	print("Bullet visibility: ", visible)
	print("Bullet mesh visibility: ", $MeshInstance3D.visible)
	
	# Ensure the bullet is visible
	visible = true
	$MeshInstance3D.visible = true
	
	# Player is on layer 1 and zombies are on layer 2
	# Using groups for reliable detection
	collision_layer = 4   # Layer 3 (bullets)
	collision_mask = 3    # Detect layers 1 & 2 (player and zombies)
	
	print("Bullet collision setup - will use group checks for hit detection")
	
	# Make the bullet more visible with a bright material
	material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.5, 0.0, 1.0)  # Bright orange
	material.emission_enabled = true
	material.emission = Color(1.0, 0.5, 0.0, 1.0)
	material.emission_energy_multiplier = 8.0  # Increased emission for better visibility
	$MeshInstance3D.material_override = material
	
	# Remove hardcoded scaling; allow scene or other code to set the mesh scale
	# $MeshInstance3D.scale = Vector3(2.0, 2.0, 2.0)  # Commented out

	# Auto-destroy after lifetime
	get_tree().create_timer(lifetime).timeout.connect(func(): queue_free())

func _physics_process(delta: float) -> void:
	# Get the forward direction from the bullet's orientation
	var forward_direction = -global_transform.basis.z.normalized()
	
	# Allow slight Y movement for aiming up/down, but limit it to prevent extreme angles
	if abs(forward_direction.y) > 0.8:
		# Limit vertical movement if it's too extreme (looking almost straight up/down)
		forward_direction.y = 0.8 * sign(forward_direction.y)
		forward_direction = forward_direction.normalized()
	
	# Apply movement
	global_position += forward_direction * speed * delta
	
	# Print position occasionally to verify movement
	if Engine.get_process_frames() % 30 == 0:  # Every 30 frames
		print("Bullet position: ", global_position)
		print("Bullet forward direction: ", forward_direction)
		print("Bullet is still visible: ", visible)
	
	# Track travel distance
	travel_distance += speed * delta
	if travel_distance > max_distance:
		print("Bullet max distance reached")
		queue_free()
	
	# Debug logging is handled by the get_process_frames() check above

func _on_body_entered(body: Node) -> void:
	# Print to help debug
	print("Bullet hit: ", body.name, " - layer: ", body.collision_layer)
	
	# First check if it's the player - if so, ignore the collision
	if body.is_in_group("PlayerCharacter"):
		print("Hit player - ignoring collision")
		return
	
	var hit_target = false
	
	# Check if it's a zombie using the group
	if body.is_in_group("Zombie") and body.has_method("take_damage"):
		hit_target = true
		print("Zombie group hit! Applying damage: ", damage)
		
		# Apply damage based on damage type
		if energy_damage:
			# Energy damage could have special effects
			body.take_damage(damage)
		else:
			body.take_damage(damage)
		
		# Handle explosion damage
		if explosion_radius > 0.0:
			apply_explosion_damage(global_position, explosion_radius, damage / 2)
		
		hits_count += 1
		
	# Fallback to check by collision layer and method
	elif body.collision_layer == 2 and body.has_method("take_damage") and not body.is_in_group("PlayerCharacter"):
		hit_target = true
		print("Zombie layer hit! Applying damage: ", damage)
		body.take_damage(damage)
		
		# Handle explosion damage
		if explosion_radius > 0.0:
			apply_explosion_damage(global_position, explosion_radius, damage / 2)
		
		hits_count += 1
	
	# Create hit effect if we hit something
	if hit_target:
		create_hit_effect()
		
		# Check if we should destroy the projectile
		if not piercing or hits_count >= max_piercing_hits:
			queue_free()
	else:
		# Non-zombie object, just remove the bullet
		print("Hit non-zombie object: ", body.name)
		queue_free()

func apply_explosion_damage(explosion_center: Vector3, radius: float, explosion_damage: int):
	# Find all zombies in explosion radius
	var zombies = get_tree().get_nodes_in_group("Zombie")
	
	for zombie in zombies:
		if not is_instance_valid(zombie):
			continue
			
		var distance = explosion_center.distance_to(zombie.global_position)
		if distance <= radius:
			# Calculate damage falloff based on distance
			var damage_multiplier = 1.0 - (distance / radius)
			var final_damage = int(explosion_damage * damage_multiplier)
			
			if final_damage > 0 and zombie.has_method("take_damage"):
				zombie.take_damage(final_damage)
				print("Explosion damaged zombie for: ", final_damage)
	
	# Create explosion visual effect
	create_explosion_effect(explosion_center, radius)

func create_explosion_effect(position: Vector3, radius: float):
	# Create a visual explosion effect
	var explosion_effect = Sprite3D.new()
	explosion_effect.texture = preload("res://icon.svg") # Using default icon as placeholder
	explosion_effect.scale = Vector3(radius * 0.5, radius * 0.5, radius * 0.5)
	explosion_effect.modulate = Color(1, 0.3, 0, 1)  # Orange explosion
	explosion_effect.global_position = position
	get_tree().root.add_child(explosion_effect)
	
	# Remove explosion effect after duration
	get_tree().create_timer(0.5).timeout.connect(func(): 
		if is_instance_valid(explosion_effect):
			explosion_effect.queue_free())

func create_hit_effect():
	# Create hit effect (small flash)
	var hit_effect = Sprite3D.new()
	hit_effect.texture = preload("res://icon.svg") # Using default icon as placeholder
	hit_effect.scale = Vector3(0.1, 0.1, 0.1)
	
	# Different colors for different damage types
	if energy_damage:
		hit_effect.modulate = Color(0.2, 0.8, 1, 1)  # Blue for energy
	else:
		hit_effect.modulate = Color(1, 0.7, 0, 1)  # Orange for normal
		
	hit_effect.global_transform.origin = global_transform.origin
	get_tree().root.add_child(hit_effect)
	
	# Remove hit effect after duration
	get_tree().create_timer(hit_effect_duration).timeout.connect(func(): 
		if is_instance_valid(hit_effect):
			hit_effect.queue_free())

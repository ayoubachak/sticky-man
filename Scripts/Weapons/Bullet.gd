extends Area3D

@export var speed: float = 50.0
@export var damage: int = 25
@export var lifetime: float = 3.0  # Maximum bullet lifetime in seconds
@export var hit_effect_duration: float = 0.1  # How long hit effects last

var travel_distance: float = 0.0
var max_distance: float = 1000.0
var material: StandardMaterial3D

# Set a higher default speed for better visibility
func _init():
	speed = 100.0  # Double the default speed to make bullets easier to see

func _ready() -> void:
	# Connect the body_entered signal for collision detection
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Add a debug print to verify bullet creation and position
	print("Bullet created at position: ", global_position)
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
	
	# Check if it's a zombie using the group
	if body.is_in_group("Zombie") and body.has_method("take_damage"):
		# Alternative method to detect zombies
		print("Zombie group hit! Applying damage: ", damage)
		body.take_damage(damage)
		
		# Create hit effect (small flash)
		var hit_effect = Sprite3D.new()
		hit_effect.texture = preload("res://icon.svg") # Using default icon as placeholder
		hit_effect.scale = Vector3(0.1, 0.1, 0.1)
		hit_effect.modulate = Color(1, 0.7, 0, 1)
		hit_effect.global_transform.origin = global_transform.origin
		get_tree().root.add_child(hit_effect)
		
		# Remove hit effect after duration
		get_tree().create_timer(hit_effect_duration).timeout.connect(func(): hit_effect.queue_free())
		
		# Remove bullet
		queue_free()
	# Fallback to check by collision layer and method (since both zombies and player are on layer 2)
	elif body.collision_layer == 2 and body.has_method("take_damage") and not body.is_in_group("PlayerCharacter"):
		# Hit a zombie
		print("Zombie layer hit! Applying damage: ", damage)
		body.take_damage(damage)
		
		# Create hit effect (small flash)
		var hit_effect = Sprite3D.new()
		hit_effect.texture = preload("res://icon.svg") # Using default icon as placeholder
		hit_effect.scale = Vector3(0.1, 0.1, 0.1)
		hit_effect.modulate = Color(1, 0.7, 0, 1)
		hit_effect.global_transform.origin = global_transform.origin
		get_tree().root.add_child(hit_effect)
		
		# Remove hit effect after duration
		get_tree().create_timer(hit_effect_duration).timeout.connect(func(): hit_effect.queue_free())
		
		# Remove bullet
		queue_free()
	else:
		# Non-zombie object, just remove the bullet
		print("Hit non-zombie object: ", body.name)
		queue_free()

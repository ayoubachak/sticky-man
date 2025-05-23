extends Node
class_name BaseWeapon

# Base weapon properties that all weapons share
@export var weapon_name: String = "Base Weapon"
@export var damage: int = 25
@export var fire_rate: float = 1.0  # Shots per second
@export var cooldown_time: float = 1.0  # Time between shots
@export var projectile_scene: PackedScene
@export var muzzle_flash_duration: float = 0.1

var last_shot_time: float = 0.0
var current_cooldown: float = 0.0

# Virtual method that each weapon must implement
func can_shoot() -> bool:
	return current_cooldown <= 0.0

func shoot(spawn_position: Vector3, spawn_rotation: Transform3D) -> bool:
	if not can_shoot():
		return false
		
	# Update cooldown
	current_cooldown = cooldown_time
	last_shot_time = Time.get_ticks_msec() / 1000.0
	
	# Create projectile
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		
		# Set the complete transform to match camera direction
		var projectile_transform = spawn_rotation
		projectile_transform.origin = spawn_position
		projectile.global_transform = projectile_transform
		
		# Apply weapon-specific properties to projectile
		configure_projectile(projectile)
		
		# Add to scene
		Engine.get_main_loop().current_scene.add_child(projectile)
		
		print(weapon_name + " fired!")
		return true
	
	return false

# Virtual method for configuring projectiles (override in derived classes)
func configure_projectile(projectile: Node):
	if projectile.has_method("set_damage"):
		projectile.set_damage(damage)

# Update cooldown
func update_cooldown(delta: float):
	if current_cooldown > 0.0:
		current_cooldown -= delta
		current_cooldown = max(current_cooldown, 0.0)

# Get cooldown percentage (0.0 = ready, 1.0 = full cooldown)
func get_cooldown_percentage() -> float:
	if cooldown_time <= 0.0:
		return 0.0
	return current_cooldown / cooldown_time 
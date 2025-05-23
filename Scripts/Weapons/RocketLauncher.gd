extends BaseWeapon
class_name RocketLauncher

func _init():
	weapon_name = "Rocket Launcher"
	damage = 100
	fire_rate = 0.5  # 0.5 shots per second (one shot every 2 seconds)
	cooldown_time = 2.0  # 2 seconds between shots
	muzzle_flash_duration = 0.2

func configure_projectile(projectile: Node):
	super.configure_projectile(projectile)
	
	# Rocket launcher specific configuration
	if projectile.has_method("set_speed"):
		projectile.set_speed(60.0)  # Slower rockets
	
	if projectile.has_method("set_explosion_radius"):
		projectile.set_explosion_radius(8.0)  # Area damage
	
	# Make rockets bigger and red
	if projectile.has_node("MeshInstance3D"):
		var mesh_instance = projectile.get_node("MeshInstance3D")
		mesh_instance.scale = Vector3(3.0, 3.0, 3.0)  # Bigger projectile
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(1.0, 0.2, 0.2, 1.0)  # Red
		material.emission_enabled = true
		material.emission = Color(1.0, 0.2, 0.2, 1.0)
		material.emission_energy_multiplier = 10.0
		mesh_instance.material_override = material 
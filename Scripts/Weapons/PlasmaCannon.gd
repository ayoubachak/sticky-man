extends BaseWeapon
class_name PlasmaCannon

func _init():
	weapon_name = "Plasma Cannon"
	damage = 60
	fire_rate = 1.5  # 1.5 shots per second
	cooldown_time = 0.67  # ~670ms between shots
	muzzle_flash_duration = 0.15

func configure_projectile(projectile: Node):
	super.configure_projectile(projectile)
	
	# Plasma cannon specific configuration
	if projectile.has_method("set_speed"):
		projectile.set_speed(80.0)  # Medium speed
	
	if projectile.has_method("set_piercing"):
		projectile.set_piercing(true)  # Can pierce through multiple enemies
	
	if projectile.has_method("set_energy_damage"):
		projectile.set_energy_damage(true)  # Energy type damage
	
	# Make plasma shots bigger and blue/purple
	if projectile.has_node("MeshInstance3D"):
		var mesh_instance = projectile.get_node("MeshInstance3D")
		mesh_instance.scale = Vector3(2.0, 2.0, 2.0)  # Bigger than bullets, smaller than rockets
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.2, 0.6, 1.0, 1.0)  # Blue-cyan
		material.emission_enabled = true
		material.emission = Color(0.2, 0.6, 1.0, 1.0)
		material.emission_energy_multiplier = 12.0
		mesh_instance.material_override = material 
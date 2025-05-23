extends BaseWeapon
class_name AssaultRifle

func _init():
	weapon_name = "Assault Rifle"
	damage = 25
	fire_rate = 5.0  # 5 shots per second
	cooldown_time = 0.2  # 200ms between shots
	muzzle_flash_duration = 0.05

func configure_projectile(projectile: Node):
	super.configure_projectile(projectile)
	
	# Assault rifle specific configuration
	if projectile.has_method("set_speed"):
		projectile.set_speed(100.0)  # Fast bullets
	
	# Set bullet color to default (orange)
	if projectile.has_node("MeshInstance3D"):
		var mesh_instance = projectile.get_node("MeshInstance3D")
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(1.0, 0.5, 0.0, 1.0)  # Orange
		material.emission_enabled = true
		material.emission = Color(1.0, 0.5, 0.0, 1.0)
		material.emission_energy_multiplier = 8.0
		mesh_instance.material_override = material 
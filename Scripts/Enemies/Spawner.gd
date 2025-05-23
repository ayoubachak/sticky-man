extends Node3D

@export var zombie_scene: PackedScene
@export var spawn_interval: float = 1
@export var map_width: float = 50.0
@export var map_depth: float = 50.0
@export var spawn_y: float = 0.0  # fixed Y level for spawning
@export var spawn_height_offset: float = 2.0  # additional height to raise spawn

# Elite zombie variables
@export var elite_chance: float = 0.3 # 30% chance to spawn elite zombie once threshold is reached
@export var elite_health_multiplier: float = 2.0
@export var elite_speed_multiplier: float = 1.5
@export var elite_damage_multiplier: float = 2.0
@export var elite_color: Color = Color(0.8, 0.1, 0.1, 1.0) # Red for elite zombies

var player: Node3D = null

func _ready() -> void:
	# Set default spawn_y to this node's height if not explicitly set
	spawn_y = global_transform.origin.y
	
	# Find the player by group
	var players = get_tree().get_nodes_in_group("PlayerCharacter")
	if players.size() > 0:
		player = players[0]
	
	# Check if Timer node exists
	if has_node("Timer"):
		var timer = $Timer
		timer.wait_time = spawn_interval
		timer.autostart = true
		timer.one_shot = false
		# Disconnect any existing connections first to avoid duplicates
		if timer.is_connected("timeout", Callable(self, "_on_Timer_timeout")):
			timer.disconnect("timeout", Callable(self, "_on_Timer_timeout"))
		# Connect the timer's timeout signal to our function
		timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
		print("Zombie spawner timer connected with interval: ", spawn_interval)
	else:
		# If no timer exists, create one
		print("No Timer node found, creating one")
		var timer = Timer.new()
		timer.name = "Timer"
		timer.wait_time = spawn_interval
		timer.autostart = true
		timer.one_shot = false
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _on_Timer_timeout() -> void:
	print("Spawning zombie...")
	var z = zombie_scene.instantiate()
	
	# pick a random position within bounds centered on this Spawner
	var center = global_transform.origin
	var x = center.x + randf() * map_width - map_width / 2.0
	var zpos = center.z + randf() * map_depth - map_depth / 2.0
	
	# use fixed Y level plus offset
	z.global_transform.origin = Vector3(x, spawn_y + spawn_height_offset, zpos)
	
	# Check player score to determine if we should spawn elite zombies
	var spawn_elite = false
	if player and player.score >= player.elite_zombie_threshold:
		# Random chance to spawn elite zombie
		spawn_elite = randf() <= elite_chance
	
	# Configure zombie based on type
	if spawn_elite:
		z.is_elite_zombie = true
		z.max_health = int(z.max_health * elite_health_multiplier)
		z.current_health = z.max_health
		z.speed = z.speed * elite_speed_multiplier
		z.attack_damage = int(z.attack_damage * elite_damage_multiplier)
		
		# Update elite zombie appearance
		if z.hit_material:
			z.hit_material.albedo_color = elite_color
		
		# Update health display
		if z.label:
			z.label.text = str(z.current_health)
			z.label.modulate = elite_color
	
	# Adjust spawn rate based on player score
	if player and player.score >= player.spawn_rate_increase_threshold:
		var timer = get_node("Timer")
		if timer and timer.wait_time > 0.3:  # Don't let it get too fast
			timer.wait_time = spawn_interval * 0.7  # 30% faster spawning
	
	# Add zombie to the scene
	get_parent().add_child(z)
	print("Zombie spawned at position: ", z.global_transform.origin)

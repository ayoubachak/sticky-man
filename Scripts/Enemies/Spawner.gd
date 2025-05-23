extends Node3D

@export var zombie_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var map_width: float = 50.0
@export var map_depth: float = 50.0
@export var spawn_y: float = 0.0  # fixed Y level for spawning
@export var spawn_height_offset: float = 2.0  # additional height to raise spawn

func _ready() -> void:
	# Set default spawn_y to this node's height if not explicitly set
	spawn_y = global_transform.origin.y
	$Timer.wait_time = spawn_interval
	$Timer.autostart = true
	$Timer.one_shot = false
	$Timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _on_Timer_timeout() -> void:
	var z = zombie_scene.instantiate()
	# pick a random position within bounds centered on this Spawner
	var center = global_transform.origin
	var x = center.x + randf() * map_width - map_width / 2.0
	var zpos = center.z + randf() * map_depth - map_depth / 2.0
	# use fixed Y level plus offset
	z.global_transform.origin = Vector3(x, spawn_y + spawn_height_offset, zpos)
	get_parent().add_child(z)

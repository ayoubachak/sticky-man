extends Node3D

@export var zombie_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var map_width: float = 50.0
@export var map_depth: float = 50.0

func _ready() -> void:
	var timer = $Timer
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _on_Timer_timeout() -> void:
	var z = zombie_scene.instantiate()
	# pick a random position within centered bounds
	var x = randf() * map_width - map_width / 2.0
	var zpos = randf() * map_depth - map_depth / 2.0
	z.global_transform.origin = Vector3(x, 0.0, zpos)
	get_parent().add_child(z)

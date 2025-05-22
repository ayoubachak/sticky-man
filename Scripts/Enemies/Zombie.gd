extends CharacterBody3D

@export var speed: float = 5.0

@onready var label: Label3D = $Label3D
var player: Node3D = null

func _ready() -> void:
	label.text = "Zombie"
	# find the player by group since the scene root is not a Node
	var players = get_tree().get_nodes_in_group("PlayerCharacter")
	if players.size() > 0:
		player = players[0]

func _physics_process(_delta: float) -> void:
	if not player:
		return
	# chase on horizontal plane
	var dir = player.global_transform.origin - global_transform.origin
	dir.y = 0
	if dir.length() > 0:
		dir = dir.normalized()
		velocity = dir * speed
		move_and_slide()

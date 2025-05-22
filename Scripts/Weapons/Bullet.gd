extends Area3D


@export var speed: float = 50.0
@export var damage: int = 25


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	# move forward along local -Z
	translate(-transform.basis.z * speed * delta)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Zombie") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

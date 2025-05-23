extends Node3D

@export_group("Knockback variables")
@export var knockbackAmount : float
@export var waitTimeBefCanUseKnobaAgain : float
var waitTimeBefCanUseKnobaAgainRef : float

# Knockback energy system
@export var knockback_max_energy: float = 1.0
var knockback_current_energy: float = 1.0
@export var knockback_energy_consumption: float = 0.2  # 20% per use
@export var knockback_energy_regen_rate: float = 0.18  # Regenerates 18% per second (fastest)

@onready var knockbackToolAttackPoint : Node3D = $KnockbackTool/KnockbackToolAttackPoint
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var hud : Control = $"../../../HUD"

signal sendKnockback

func _ready():
	waitTimeBefCanUseKnobaAgainRef = waitTimeBefCanUseKnobaAgain
	
func _process(delta):
	use(delta)
	
	timeManagement(delta)
	
	# Regenerate energy
	regenerate_energy(delta)
	
	sendProperties()
	
func use(_delta : float):
	if Input.is_action_just_pressed("useKnockbackTool"):
		# Use energy system instead of cooldown
		if can_use_knockback():
			use_knockback_energy()
			emit_signal("sendKnockback", knockbackAmount, -global_transform.basis.z.normalized())
			animationPlayer.play("useKnockbackTool")
			print("Knockback used! Energy remaining: ", knockback_current_energy)
	
func timeManagement(delta : float):
	if waitTimeBefCanUseKnobaAgain > 0.0: waitTimeBefCanUseKnobaAgain -= delta
	
func sendProperties():
	#display knockback tool properties
	hud.displayKnockbackToolWaitTime(waitTimeBefCanUseKnobaAgain)
	
	# Update knockback ability bar with energy system
	if hud.has_method("update_knockback_bar_energy"):
		hud.update_knockback_bar_energy(knockback_current_energy, knockback_max_energy, knockback_energy_consumption)
	elif hud.has_method("update_knockback_bar"):
		# Fallback for compatibility
		hud.update_knockback_bar(waitTimeBefCanUseKnobaAgain, waitTimeBefCanUseKnobaAgainRef)

# Check if knockback tool has enough energy
func can_use_knockback() -> bool:
	return knockback_current_energy >= knockback_energy_consumption

# Consume energy when using knockback
func use_knockback_energy():
	knockback_current_energy -= knockback_energy_consumption
	knockback_current_energy = max(knockback_current_energy, 0.0)

# Regenerate knockback energy over time
func regenerate_energy(delta: float):
	if knockback_current_energy < knockback_max_energy:
		knockback_current_energy += knockback_energy_regen_rate * delta
		knockback_current_energy = min(knockback_current_energy, knockback_max_energy)

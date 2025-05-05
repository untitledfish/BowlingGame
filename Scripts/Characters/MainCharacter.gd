extends CharacterBody2D

#Left/Right or A/D: Move
#Shift + Move: Run
#Space: Jump
#CTRL = Dash (1 sec cooldown)

#Variables
const walk_speed = 3000
const run_speed = 5000
const dash_speed = 3000
const jump_height = -500
var last_input = 0
var can_dash = true
var can_jump = true
var dashing = false
var jump_curr = 0
var jump_cap = 1
var health: = 100
var is_invincible: = false
var dash_unlocked = true
var djump_unlocked = true
var kill_count = 0
var knockback_force: Vector2 = Vector2.ZERO  # Stores knockback temporarily
var knockback_decay: float = 0.1  # How fast knockback fades (0.1 = smooth, 1 = instant)
@export var invincibility_time: float = 2.5  # seconds
@export var roll_multiplier = 0.01
@onready var invincibility_timer = $InvincibilityTimer  # Timer node
@onready var hit_particles = $HitParticles  # CPUParticles2D or GPUParticles2D
@onready var hit_sound = $HitSound  # AudioStreamPlayer2D
@onready var sprite = $BallSprite
@onready var ground_dash_effect = $GroundDashEffect
@onready var air_dash_effect = $AirDashEffect
@onready var jump_effect = $JumpEffect
signal dmg_taken

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	invincibility_timer.wait_time = invincibility_time
	invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)
	
func _physics_process(delta: float) -> void:
	#Move left and right. If Shift is held, move faster
	var move_input = Input.get_axis("ui_left", "ui_right")
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).normalized()
		
	# Horizontal movement blended with knockback
	if dashing:
		# Let dash control velocity fully during dash time
		pass  # Do nothing, let dash handle it
	else:
		if move_input and Input.is_action_pressed("Run") and dashing == false:
			var target_velocity_x = float(move_input) * run_speed
			velocity.x = lerp(knockback_force.x, target_velocity_x, knockback_decay)
		elif move_input and dashing == false:
			var target_velocity_x = float(move_input) * walk_speed
			velocity.x = lerp(knockback_force.x, target_velocity_x, knockback_decay)
		else:
			# Blend towards 0 when idle, to let knockback slowly fade
			velocity.x = lerp(knockback_force.x, 0.0, knockback_decay)

	# Slowly reduce knockback force (for one-time pushes)
	knockback_force.x = lerp(knockback_force.x, 0.0, knockback_decay)
	
	#Floor check
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.length() > 0 && Input.is_action_pressed("ui_left"):
			var rotation_amount = velocity.length() * delta * (roll_multiplier / 3)
			sprite.rotation -= rotation_amount
		else:
			var rotation_amount = velocity.length() * delta * (roll_multiplier / 3)
			sprite.rotation += rotation_amount
	else:
		jump_curr = 0
		if velocity.length() > 0 && Input.is_action_pressed("ui_left"):
			var rotation_amount = velocity.length() * delta * roll_multiplier
			sprite.rotation -= rotation_amount
		else:
			var rotation_amount = velocity.length() * delta * roll_multiplier
			sprite.rotation += rotation_amount
	
# Jumping (Space)
	if Input.is_key_pressed(KEY_SPACE) and can_jump:
		if is_on_floor():  
			velocity.y = jump_height
			jump_curr = 1 
			can_jump = false
			await get_tree().create_timer(0.5).timeout 
			can_jump = true
		elif jump_curr < jump_cap and djump_unlocked: 
			velocity.y = jump_height
			jump_effect.visible = true
			await get_tree().create_timer(0.05).timeout
			jump_effect.visible = false
			jump_curr += 1 
			can_jump = false
			await get_tree().create_timer(0.5).timeout
			can_jump = true

	# Reset jumps when landing
	if is_on_floor():
		jump_curr = 0
	
	#Dashing (CTLR)
	if Input.is_key_pressed(KEY_CTRL) and move_input and (can_dash == true) and dashing == false and dash_unlocked:
		last_input = move_input
		dashing = true
		velocity.x = dash_speed * last_input
		velocity.y = -9.8
		ground_dash_effect.flip_h = velocity.x < 0
		air_dash_effect.flip_h = velocity.x < 0
		
		if is_on_floor():
			ground_dash_effect.visible = true
		else:
			air_dash_effect.visible = true
		await get_tree().create_timer(0.15).timeout
		can_dash = false
		dashing = false
		ground_dash_effect.visible = false
		air_dash_effect.visible = false
		$DashCD.start()
		
	move_and_slide()
	
	if is_invincible:
		sprite.modulate = Color(1, 0.5, 0.5)  # Tint red or flash effect

#Dash cooldown
func _on_dash_cd_timeout() -> void:
	print("Dash ready!")
	can_dash = true

func take_damage(amount: int, knockback: Vector2):
	dmg_taken.emit()
	if is_invincible:
		return
	health -= amount
	print("Player health: ", health)
	knockback_force = knockback
	# Play hit effects
	hit_particles.restart()
	hit_sound.play()
	# Start invincibility
	is_invincible = true
	invincibility_timer.start()
	if health <= 0:
		die()

func die():
	print("Player died!")
	get_tree().change_scene_to_file("res://Scenes/Maps/level_1.tscn")

func _on_invincibility_timer_timeout():
	is_invincible = false
	sprite.modulate = Color(1, 1, 1)  # Reset to normal

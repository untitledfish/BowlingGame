extends CharacterBody2D

#Left/Right or A/D: Move
#Shift + Move: Run
#Space: Jump
#CTRL = Dash (1 sec cooldown)

#Variables
const walk_speed = 300
const run_speed = 500
const dash_speed = 3000
const jump_height = -500
var last_input = 0
var can_dash = true
var can_jump = true
var jump_curr = 0
var jump_cap = 1

var dash_unlocked = true
var djump_unlocked = true

@onready var sprite = $BallSprite
@export var roll_multiplier = 0.01
@onready var ground_dash_effect = $GroundDashEffect
@onready var air_dash_effect = $AirDashEffect
@onready var jump_effect = $JumpEffect

#State variables
var dashing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	#Move left and right. If Shift is held, move faster
	var move_input = Input.get_axis("ui_left", "ui_right")
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).normalized()
	if move_input and Input.is_action_pressed("Run") and dashing == false:
		velocity.x = move_input * run_speed
	elif move_input and dashing == false:
		velocity.x = move_input * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0 , walk_speed)
	
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

#Dash cooldown
func _on_dash_cd_timeout() -> void:
	print("Dash ready!")
	can_dash = true

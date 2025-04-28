extends CharacterBody2D

const Bullet = preload("res://Scripts/Characters/basic_bullet.gd")
var player: Node2D = null
var player_detected: bool = false
var current_fire_rate: float = base_fire_rate
@export var gravity: float = 1200.0
@export var max_fall_speed: float = 400.0
@export var speed: float = 100.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 1.0
@export var base_fire_rate: float = 1.0  # Starting fire rate (seconds)
@export var min_fire_rate: float = 0.2   # Minimum allowed fire rate
@export var fire_rate_decay: float = 0.2 # Amount to reduce after each shot
@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionRange
@onready var muzzle = $Muzzle
@onready var fireRate = $Firerate

func _ready():
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	fireRate.timeout.connect(_on_fireRate_timeout)
	fireRate.wait_time = current_fire_rate

func _physics_process(delta):
	# Apply gravity to the vertical velocity
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, max_fall_speed)
	if player_detected and player:
		var to_player = player.global_position - global_position
		# Flip to face player
		sprite.scale.x = abs(sprite.scale.x) * -sign(to_player.x)
		# Flip muzzle position based on direction
		var muzzle_offset = abs(muzzle.position.x)
		muzzle.position.x = muzzle_offset * -sign(sprite.scale.x)
	else:
		velocity.x = 0.0
	move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player_detected = true
		fireRate.start()

func _on_body_exited(body):
	if body == player:
		player_detected = false
		player = null
		fireRate.stop()
		current_fire_rate = base_fire_rate  # Reset fire rate
		
func shoot_at_player():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	var to_player = player.global_position - muzzle.global_position
	var direction_to_player = to_player.normalized()
	var angle_to_player = direction_to_player.angle()
	# Determine facing direction
	var base_direction = Vector2.RIGHT if sprite.scale.x < 0 else Vector2.LEFT
	var base_angle = base_direction.angle()
	# Calculate relative angle difference
	var angle_diff = wrapf(angle_to_player - base_angle, -PI, PI)
	# Maximum allowed angle in radians (45°)
	var max_aim_angle = deg_to_rad(45)
	var final_direction: Vector2
	if abs(angle_diff) <= max_aim_angle:
		# Player is within aim cone, shoot at them
		final_direction = direction_to_player
	else:
		# Player is outside aim cone, shoot straight ahead
		final_direction = base_direction
	# Set bullet properties
	bullet.velocity = final_direction.normalized() * bullet.speed
	bullet.rotation = final_direction.angle()
	get_tree().current_scene.add_child(bullet)

func _on_fireRate_timeout():
	if player_detected and player:
		shoot_at_player()
		# Reduce fire rate for next shot, but clamp to minimum
		current_fire_rate = max(min_fire_rate, current_fire_rate - fire_rate_decay)
		fireRate.wait_time = current_fire_rate
		fireRate.start()  # Restart with new, shorter interval

extends KinematicBody2D

export var speed := 250
export var jump_force := 750
export var gravity := 2000
export var coyote_time := 0.1
export var jump_buffer_time := 0.1
export var max_jumps := 2
export var double_jump_multiplier := 0.7
export var max_fall_speed := 2500

var velocity = Vector2.ZERO
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var jumps_left = 0
var arah = "diam"
var last_dir = "kanan"  # Arah terakhir saat diam
var is_attacking = false

onready var sprite: AnimatedSprite = $AnimatedSprite

func _ready():
	sprite.connect("animation_finished", self, "_on_animation_finished")

func _physics_process(delta):
	# --- Gravitasi & lompat ---
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		coyote_timer = coyote_time
		jumps_left = max_jumps

	velocity.y = min(velocity.y, max_fall_speed)

	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# --- Input kiri/kanan ---
	var input_dir = 0
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1
		arah = "kiri"
	elif Input.is_action_pressed("ui_right"):
		input_dir += 1
		arah = "kanan"
	else:
		arah = "diam"

	if arah != "diam":
		last_dir = arah

	velocity.x = input_dir * speed

	# --- Lompat buffer ---
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time

	if jump_buffer_timer > 0 and (coyote_timer > 0 or jumps_left > 0):
		if jumps_left == max_jumps:
			velocity.y = -jump_force
		else:
			velocity.y = -jump_force * double_jump_multiplier
		jump_buffer_timer = 0
		coyote_timer = 0
		jumps_left -= 1

	# --- Attack saat mouse ditekan ---
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if not is_attacking:
			is_attacking = true
			sprite.speed_scale = 4.0
			sprite.play("attack")
		sprite.flip_h = last_dir == "kiri"
	else:
		if is_attacking:
			is_attacking = false
			sprite.stop()
			sprite.speed_scale = 1.0
			# Langsung animasi jalan/diam
			if velocity.x != 0:
				sprite.flip_h = velocity.x < 0
				sprite.play("jalan_kanan")
			else:
				sprite.play("diam")

	# --- Update animasi jalan/diam saat tidak attack ---
	if not is_attacking:
		sprite.speed_scale = 1.0
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0
			sprite.play("jalan_kanan")
		else:
			sprite.play("diam")

	# --- Gerakkan player ---
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			# restart attack jika mouse masih ditekan
			sprite.speed_scale = 2.0
			sprite.play("attack")
			sprite.flip_h = last_dir == "kiri"
		else:
			is_attacking = false
			sprite.speed_scale = 1.0
			if velocity.x != 0:
				sprite.flip_h = velocity.x < 0
				sprite.play("jalan_kanan")
			else:
				sprite.play("diam")

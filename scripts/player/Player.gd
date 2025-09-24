extends KinematicBody2D

export var speed := 250
export var jump_force := 750
export var gravity := 2000
export var coyote_time := 0.1
export var jump_buffer_time := 0.1
export var max_jumps := 2
export var double_jump_multiplier := 0.9
export var max_fall_speed := 2500   # batas kecepatan jatuh biar ga terlalu berat

var velocity = Vector2.ZERO
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var jumps_left = 0

onready var sprite = $Sprite

func _physics_process(delta):
	# Tambah gravitasi
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		coyote_timer = coyote_time
		jumps_left = max_jumps

	# Batasi kecepatan jatuh
	velocity.y = min(velocity.y, max_fall_speed)

	# Kurangi timer
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# Input kiri/kanan
	var input_dir = 0
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir += 1
	velocity.x = input_dir * speed

	# Balik sprite sesuai arah gerak
	if input_dir != 0:
		sprite.flip_h = input_dir < 0

	# Input lompat → buffer
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time

	# Lompat (cek normal jump atau double jump)
	if jump_buffer_timer > 0 and (coyote_timer > 0 or jumps_left > 0):
		if jumps_left == max_jumps:  
			velocity.y = -jump_force
		else:
			velocity.y = -jump_force * double_jump_multiplier

		jump_buffer_timer = 0
		coyote_timer = 0
		jumps_left -= 1
	
	# Gerakkan player
	velocity = move_and_slide(velocity, Vector2.UP)

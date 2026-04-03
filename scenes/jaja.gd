extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

# Referenca na AnimatedSprite2D čvor
@onready var sprite = $AnimatedSprite2D

# Varijabla koja prati napada li igrač trenutno
var is_attacking = false

func _physics_process(delta: float) -> void:
	# 1. Dodavanje gravitacije
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Napad (Attack)
	# Koristimo "ui_focus_next" kao primjer (Tab), zamijeni s "attack" u Input Map-u
	if Input.is_action_just_pressed("ui_focus_next") and not is_attacking:
		attack()

	# 3. Skok (Jump)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 4. Kretanje (Walk)
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Okretanje sprite-a ovisno o smjeru
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# 5. Ažuriranje animacija
	update_animations(direction)

func update_animations(direction):
	# Ako napadamo, ne mijenjaj animaciju dok ne završi
	if is_attacking:
		return
		
	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

func attack():
	is_attacking = true
	sprite.play("attack")
	
	# Čekamo da animacija završi prije nego dopustimo kretanje/drugu animaciju
	await sprite.animation_finished
	is_attacking = false

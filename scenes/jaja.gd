extends CharacterBody2D

const SPEED = 1000000.0
const JUMP_VELOCITY = -600.0

# Referenca na tvoj AnimatedSprite2D čvor
@onready var sprite = $AnimatedSprite2D

var is_attacking = false

func _physics_process(delta: float) -> void:
	# 1. Gravitacija
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Napad (LMB klik)
	# Napomena: Moraš dodati "attack" u Project Settings -> Input Map
	if Input.is_action_just_pressed("attack") and not is_attacking:
		perform_attack()

	# 3. Skok
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY

	# 4. Kretanje (Lijevo/Desno)
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Okretanje lika (ako ne napadaš, dopusti okretanje)
	if not is_attacking:
		if direction > 0:
			sprite.flip_h = false
		elif direction < 0:
			sprite.flip_h = true

	# Kretanje se usporava ako napadamo (opcionalno, ovisi o tvojoj igri)
	if direction and not is_attacking:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# 5. Upravljanje animacijama
	update_animations(direction)

func update_animations(direction):
	# Ako je napad u tijeku, ne mijenjaj animaciju
	if is_attacking:
		return
		
	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

func perform_attack():
	is_attacking = true
	sprite.play("attack")
	
	# Čekamo da animacija završi
	await sprite.animation_finished
	is_attacking = false

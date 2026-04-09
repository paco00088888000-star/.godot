extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

@onready var sprite = $AnimatedSprite2D

var is_attacking = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Napad - pokreće se samo ako već ne napadamo
	if Input.is_action_just_pressed("attack") and not is_attacking:
		perform_attack()

	# Skok i kretanje su onemogućeni tijekom napada radi bolje kontrole
	if not is_attacking:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		update_animations(direction)
	else:
		# Tijekom napada lik se polako zaustavlja
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.1)

	move_and_slide()

func update_animations(direction):
	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

func perform_attack():
	is_attacking = true
	sprite.play("attack")
	
	# Povezujemo signal koji će se okinuti ČIM animacija završi
	# Koristimo jednokratno povezivanje (CONNECT_ONE_SHOT) za sigurnost
	if not sprite.animation_finished.is_connected(_on_attack_finished):
		sprite.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)

func _on_attack_finished():
	# Ova funkcija se pokreće samo kad animacija "stvarno" dođe do kraja
	if sprite.animation == "attack":
		is_attacking = false
		sprite.stop() # Prisilno zaustavljanje

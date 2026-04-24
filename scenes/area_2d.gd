extends Area2D

@onready var target = $TargetPos # Putanja do markera
@export var animation_name: String = "spin"

func _on_body_entered(body):
	if body is CharacterBody2D:
		# 1. Izračunaj visinu (udaljenost po Y osi)
		var height = global_position.y - target.global_position.y
		
		
		
		# 3. Formula za početnu brzinu: v = sqrt(2 * g * h)
		# Koristimo negativno jer je u Godotu "gore" minus Y
		var push_velocity = -sqrt(2 * gravity * height)
		
		# 4. Primijeni brzinu na igrača
		body.velocity.y = push_velocity
		
		# 5. Pokreni animaciju
		var anim = body.get_node_or_null("AnimatedSprite2D")
		if anim:
			anim.play(animation_name)

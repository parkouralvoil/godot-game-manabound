extends Node2D
class_name PlayerHitComponent

@onready var p: Player = owner
@onready var t_iframe: Timer = $iframe_cd
@onready var hit_particles: GPUParticles2D = $GPUParticles2D

@export var sfx_hit: AudioStream

# iframes stuff
var max_iframes: int = 5
var iframes: int = 0

# colors
var red_hit: Color = Color(1,0.5,0.5, 1)
var white: Color = Color(1,1,1,1)
var gray_faded: Color = Color(0.5,0.5,0.5, 0.8)

func player_hit() -> void:
	iframes = max_iframes
	t_iframe.start()
	p.anim_sprite.modulate = red_hit
	SoundPlayer.play_sound(sfx_hit, -18, 1.1)
	
	hit_particles.restart()

func _on_iframe_cd_timeout() -> void:
	iframes -= 1
	var tween: Tween = create_tween()
	tween.tween_property(p.anim_sprite, "modulate", gray_faded, 0.1)
	tween.tween_property(p.anim_sprite, "modulate", white, 0.1)

	if iframes > 0:
		t_iframe.start()

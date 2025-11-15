extends Node

@onready var player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(player)
	var stream = preload("res://assets/audio/bgm.mp3")
	
	# Aktifkan loop kalau stream-nya support
	if "loop" in stream:
		stream.loop = true
	elif "loop_mode" in stream:
		stream.loop_mode = 1 # LOOP_FORWARD
	
	player.stream = stream
	player.play()

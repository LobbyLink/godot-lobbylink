extends MultiplayerSpawner

func _spawn_custom(data):
	var player_scene = preload("res://addons/lobbylink/example/scenes/player.tscn")
	var player = player_scene.instantiate()
	player.name = str(data.peer_id)
	return player

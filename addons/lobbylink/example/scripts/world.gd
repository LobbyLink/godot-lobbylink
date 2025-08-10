extends Node3D

func _ready() -> void:
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(add_player)
	
	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)
	
	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)
	pass

func _exit_tree():
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)

func add_player(id: int):
	var player_scene = preload("res://addons/lobbylink/example/scenes/player.tscn")
	var player = player_scene.instantiate()
	player.set_multiplayer_authority(id)
	player.name = str(id)
	$Players.add_child(player)

func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()

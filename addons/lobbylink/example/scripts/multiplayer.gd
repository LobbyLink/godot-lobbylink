extends Node

signal spawn_player(id: int)
signal world_loaded()

func _ready() -> void:
	LobbyLink.received_room_code.connect(_on_received_room_code)
	LobbyLink.received_id.connect(_on_received_id)
	LobbyLink.room_join_successful.connect(_on_room_join_successful)
	LobbyLink.room_join_unsuccessful.connect(_on_room_join_unsuccessful)
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	pass

func _on_received_room_code(room_code: String):
	print("Server: Received Room Code %s." % [LobbyLink.get_room_code()])
	DisplayServer.window_set_title("Server: %s" % [room_code]) 
	start_game()
	pass

func _on_received_id(id: int):
	print("Client: Received ID %s." % [LobbyLink.get_id()])
	DisplayServer.window_set_title("Client: %s" % [id]) 
	pass

func _on_peer_connected(to: int):
	if LobbyLink.get_is_server():
		print("Server %s connected client peer %s." % [LobbyLink.get_room_code(), to])
	else:
		print("Client %s connected to Server %s." % [LobbyLink.get_id(), LobbyLink.get_room_code()])
		start_game()
	pass

func _on_room_join_successful():
	print("Join request successful for Lobby %s." % [LobbyLink.get_room_code()])
	print("Starting to connect peers.")
	pass

func _on_room_join_unsuccessful():
	# Let the user try again. Variables and connections get resetted in the Background.
	print("Connection to Room %s could not be established.")
	pass

func start_game():
	# Hide the UI and unpause to start the game.
	$Lobby.hide()
	get_tree().paused = false
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		change_level.call_deferred(load("res://addons/lobbylink/example/scenes/world.tscn"))

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())

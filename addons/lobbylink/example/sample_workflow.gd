extends Node

func _ready() -> void:
	LobbyLink.received_room_code.connect(_on_received_room_code)
	LobbyLink.received_id.connect(_on_received_id)
	LobbyLink.room_join_result.connect(_on_room_join_result)
	multiplayer.peer_connected.connect(_on_peer_connected)
	pass

func _on_client_button_pressed() -> void:
	var room_code = $ContainerLogin/RoomCodeInput.text
	if len(room_code) != 4: return
	LobbyLink.init_client(room_code)
	$ContainerLogin.visible = false
	pass

func _on_server_button_pressed() -> void:
	LobbyLink.init_server()
	$ContainerLogin.visible = false
	pass

func _on_received_room_code(room_code: String):
	print("Server: Received Room Code %s." % [LobbyLink.get_room_code()])
	$ContainerInfos/Room.text = room_code
	$ContainerInfos/ID.text = str(LobbyLink.get_id())
	$ContainerInfos.visible = true
	pass

func _on_received_id(id: int):
	print("Client: Received ID %s." % [LobbyLink.get_id()])
	$ContainerInfos/ID.text = id
	pass

func _on_peer_connected(to: int):
	if LobbyLink.get_is_server():
		print("Server %s connected client peer %s." % [LobbyLink.get_room_code(), to])
	else:
		print("Client %s connected to Server %s." % [LobbyLink.get_id(), LobbyLink.get_room_code()])
	pass

func _on_room_join_result(successful: bool):
	if successful:
		$ContainerInfos/Room.text = LobbyLink.get_room_code()
		$ContainerInfos.visible = true
		print("Join request successful for Lobby %s." % [LobbyLink.get_room_code()])
		print("Starting to connect peers.")
		return
	
	# Let the user try again. Lobbylink is resetting the variables in the background.
	print("Connection to Room %s could not be established." % [LobbyLink.get_room_code()])
	print("Room %s is probably full or doesn't exist." % [LobbyLink.get_room_code()])
	print("Please try again.")
	pass

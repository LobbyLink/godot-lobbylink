extends Control

func _ready() -> void:
	LobbyLink.received_room_code.connect(_on_received_room_code)
	LobbyLink.received_id.connect(_on_received_id)
	LobbyLink.peer_connected.connect(_on_peer_connected)
	LobbyLink.room_join_successful.connect(_on_room_join_successful)
	LobbyLink.room_join_unsuccessful.connect(_on_room_join_unsuccessful)
	pass

func _on_client_button_pressed() -> void:
	# Call the init_client(room_code) method to receive a ID. 
	# Disable all other input or change Scene.
	var room_code = $Container/RoomCodeInput.text
	if len(room_code) != 4: return
	LobbyLink.init_client(room_code)
	_disable_input() # Alternatively Change Scene
	pass 

func _on_server_button_pressed() -> void:
	# Call the init_server() Method to receive a Room Code.
	# Disable all other input or change Scene.
	LobbyLink.init_server()
	_disable_input() # Alternatively Change Scene
	pass

func _on_received_room_code(room_code: String):
	print("Server: Received Room Code %s." % [LobbyLink.get_room_code()])
	pass

func _on_received_id(id: int):
	print("Client: Received ID %s." % [LobbyLink.get_id()])
	pass

func _on_peer_connected():
	if LobbyLink.get_is_server():
		print("Server %s connected client peer %s." % [LobbyLink.get_room_code(), LobbyLink.get_id()])
	else:
		print("Client %s connected to Server %s." % [LobbyLink.get_id(), LobbyLink.get_room_code()])
	pass

func _on_room_join_successful():
	print("Join request successful for Lobby %s." % [LobbyLink.get_room_code()])
	print("Starting to connect peers.")
	pass

func _on_room_join_unsuccessful():
	# Let the user try again. Variables and connections get resetted in the Background.
	print("Connection to Room %s could not be established.")
	pass

func _disable_input():
	$Container/ClientButton.disabled = true
	$Container/ServerButton.disabled = true
	$Container/RoomCodeInput.editable = false
	pass

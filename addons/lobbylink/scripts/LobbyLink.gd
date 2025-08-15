extends Node
## Main Class of the LobbyLink plugin.
## Only this class should be called directly; none of the others should be used externally.


## Emitted when a server receives a room code from the signaling server.
## The room code is a short, human-readable identifier used to join a server.
## Will only be emitted on servers.
signal received_room_code(room_code: String)

## Emitted when a client receives a unique ID from the signaling server.
## The ID uniquely identifies the peer in the session.
signal received_id(id: int)

## Emitted after attempting to join a room, indicating whether it was successful.
## This is only the result for trying to join a session on the signaling server. 
## This isnot the result of the WebRTC connection! 
signal room_join_result(successful: bool)


# Should no be set by the user. Only by code.
var _id: int = 0
var _room_code: String = ""
var _is_server: bool = false


func _ready() -> void:
	# Connects signal handlers.
	received_room_code.connect(_on_received_room_code)
	received_id.connect(_on_received_id)
	room_join_result.connect(_on_room_join_result)
	pass

## Initializes a client that wants to connect to a server.
## @param room_code The room code provided by the server peer the user wants to connect to. 
## After initialization, a unique id will be emitted via [signal received_id] (Only on Clients).
func init_client(room_code: String) -> void:
	_room_code = room_code
	LobbyLink_WebSocketConnection.connect_to_signaling_server()
	pass

## Initializes a server that clients can connect to.
## After initialization, a room code will be emitted via [signal received_room_code] (Only on Servers).
func init_server() -> void:
	_is_server = true
	_id = 1
	LobbyLink_WebSocketConnection.connect_to_signaling_server()
	LobbyLink_WebRTCConnection.init_server()
	pass

# Handles the received_room_code signal.
# Stores the received room code locally.
func _on_received_room_code(room_code: String) -> void:
	_room_code = room_code
	pass

# Handles the received_id signal.
# Stores the new ID and requests to join the room via the signaling server.
func _on_received_id(new_id: int) -> void:
	_id = new_id
	LobbyLink_WebSocketMessage.msg_req_join()
	pass

# Handles the room_join_result signal.
# If successful, initializes the WebRTC client connection.
# If not, resets the connection state.
func _on_room_join_result(successful: bool) -> void:
	if successful:
		LobbyLink_WebRTCConnection.init_client()
	else:
		_reset_connection()
	pass

# Resets all connection-related data to defaults.
# This includes clearing the peer ID, room code, and server status flag.
func _reset_connection() -> void:
	# TODO: Close connection from websocket server.
	
	multiplayer.multiplayer_peer = null
	
	_id = 0
	_room_code = ""
	_is_server = false
	pass

## Returns whether the current peer is acting as the server.
func get_is_server() -> bool:
	return _is_server

## Returns the unique ID assigned to the current peer.
func get_id() -> int:
	return _id

## Returns the current room code used by this peer.
func get_room_code() -> String:
	return _room_code

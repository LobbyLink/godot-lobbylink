extends Node
## Bla Bla Bla

signal received_room_code(code: String)
signal received_id(id: int)
signal room_join_successful
signal room_join_unsuccessful
signal peer_connected(to: int)

var _id: int = 0
var _room_code: String = ""
var _is_server: bool = false

func _ready() -> void:
	received_room_code.connect(_on_received_room_code)
	received_id.connect(_on_received_id)
	room_join_successful.connect(_on_room_join_successful)
	room_join_unsuccessful.connect(_on_room_join_unsuccessful)
	pass

## Call this method to initialize a client that wants to connect to a Server.
## The function expects a [code]room_code[/code]. 
func init_client(room_code: String):
	_room_code = room_code
	LobbyLink_WebSocketConnection.connect_to_signaling_server()
	pass

func init_server():
	_is_server = true
	_id = 1
	LobbyLink_WebSocketConnection.connect_to_signaling_server()
	LobbyLink_WebRTCConnection.init_server()
	pass

func _on_received_room_code(new_room_code: String):
	_room_code = new_room_code
	pass

func _on_received_id(new_id: int):
	_id = new_id
	LobbyLink_WebSocketMessage.msg_req_join()
	pass

func _on_room_join_successful():
	LobbyLink_WebRTCConnection.init_client()
	pass

func _on_room_join_unsuccessful():
	_reset_connection()
	pass

func _reset_connection():
	# TODO: Reset Connection
	
	_id = 0
	_room_code = ""
	_is_server = false
	pass

# Getter
func get_is_server():
	return _is_server

func get_id():
	return _id

func get_room_code():
	return _room_code

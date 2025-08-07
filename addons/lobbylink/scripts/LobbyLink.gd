extends Node

signal received_room_code(code: String)
signal received_id(id: int)
signal websocket_join_successful(successful: bool)
signal webrtc_connected

var _id: int = 0
var _room_code: String = ""
var _is_server: bool = false

func _ready() -> void:
	received_room_code.connect(_on_received_room_code)
	received_id.connect(_on_received_id)
	websocket_join_successful.connect(_on_websocket_join_successful)
	webrtc_connected.connect(_on_webrtc_connected)
	pass

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
	print("Received unique room code %s." % [_room_code])
	pass

func _on_received_id(new_id: int):
	_id = new_id
	LobbyLink_WebSocketMessage.msg_req_join()
	print("Received unique ID %s." % [_id])
	pass

func _on_websocket_join_successful(successful: bool):
	if successful:
		print("Join request successful for Lobby %s.\nStarting connection via WebRTC." % [_room_code])
		LobbyLink_WebRTCConnection.init_client()
	else:
		print("Connection to Lobby %s could not be established." % [_room_code])
		# TODO: Show Fail in Screen and Reset Scenes and Variables
	pass

# Getter

func get_is_server():
	return _is_server

func get_id():
	return _id

func get_room_code():
	return _room_code

func _on_webrtc_connected():
	get_tree().change_scene_to_file("res://scenes/Test.tscn")
	pass

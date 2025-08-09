extends Node

# Enum of all Message Types that can be send
enum MessageType{
	Id,
	RoomCode,
	Join,
	Offer,
	Answer,
	Candidate,
	UserConnected,
	UserDisconnected,
	CheckIn
}

# Receives the message and processes it based on it's message type
func handle_message(message: String):
	var data: Dictionary = JSON.parse_string(message)
	var type: MessageType = int(data["type"])
	
	match type:
		MessageType.Id:
			_handle_id_msg(data)
		MessageType.RoomCode:
			_handle_room_code_msg(data)
		MessageType.Join:
			_handle_join_msg(data)
		MessageType.Offer:
			_handle_offer_msg(data)
		MessageType.Answer:
			_handle_answer_msg(data)
		MessageType.Candidate:
			_handle_candidate_msg(data)
	pass

# Send Message
func _send_packet(packet: Dictionary):
	LobbyLink_WebSocketConnection.socket.send_text(JSON.stringify(packet))
	pass

# Handle each type of message the game can receive
func _handle_id_msg(data: Dictionary):
	var id: int = int(data.id)
	LobbyLink.received_id.emit(id)
	pass

# Handle each type of message the game can receive
func _handle_room_code_msg(data: Dictionary):
	var room_code: String = data.room_code
	LobbyLink.received_room_code.emit(room_code)
	pass

func _handle_join_msg(data: Dictionary):
	var succcessful: bool = bool(data.successful)
	if succcessful:
		LobbyLink_WebRTCConnection.init_client()
		LobbyLink.room_join_successful.emit()
	else:
		LobbyLink.room_join_unsuccessful.emit()
	pass

func _handle_answer_msg(data: Dictionary):
	LobbyLink_WebRTCConnection.remote_description_received.emit(data.webrtc_type, data.sdp, data.from)
	pass

func _handle_offer_msg(data: Dictionary):
	LobbyLink_WebRTCConnection.add_remote_peer(data.webrtc_type, data.sdp, int(data.from))
	pass

func _handle_candidate_msg(data: Dictionary):
	LobbyLink_WebRTCConnection.ice_candidate_received.emit(data.media, data.index, data.name, int(data.from))
	pass

# Predefined functions to make the way of building messages easier
func msg_req_id() -> void:
	_send_packet({ "type": MessageType.Id })
	pass

func msg_req_room_code() -> void:
	_send_packet({ "type": MessageType.RoomCode })
	pass

func msg_req_join() -> void:
	_send_packet({ "type": MessageType.Join, "room_code": LobbyLink.get_room_code(), "from": LobbyLink.get_id() })
	pass

func msg_send_offer(webrtc_type: String, sdp: String) -> void:
	_send_packet({ "type": MessageType.Offer, "room_code": LobbyLink.get_room_code(), "from": LobbyLink.get_id(), "to": 1, "webrtc_type": webrtc_type, "sdp": sdp })
	pass

func msg_send_answer(webrtc_type: String, sdp: String, to: int) -> void:
	_send_packet({ "type": MessageType.Answer, "room_code": LobbyLink.get_room_code(), "from": LobbyLink.get_id(), "to": to, "webrtc_type": webrtc_type, "sdp": sdp })
	pass

func msg_send_candidate(media: String, index: int, ice_name: String, to: int) -> void:
	_send_packet({ "type": MessageType.Candidate, "room_code": LobbyLink.get_room_code(), "from": LobbyLink.get_id(), "to": to, "media": media, "index": index, "name": ice_name })
	pass

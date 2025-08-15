extends Node

signal remote_description_received(type: String, sdp: String, from: int)
signal ice_candidate_received(media: String, index: int, ice_name: String, from: int)

var _rtc_mtp: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()

@onready var _ice_servers: Dictionary = {
		"iceServers": [
			{
				"urls": [ "stun:%s:%s" % [LobbyLink_ConfigHandler.STUN_IP, LobbyLink_ConfigHandler.STUN_PORT] ], # One or more STUN servers.
			},
			{
				"urls": [ "turn:%s:%s" % [LobbyLink_ConfigHandler.TURN_IP, LobbyLink_ConfigHandler.TURN_PORT] ], # One or more TURN servers.
				"username": "%s" % LobbyLink_ConfigHandler.TURN_USERNAME, # Optional username for the TURN server.
				"credential": "%s" % LobbyLink_ConfigHandler.TURN_CREDENTIAL, # Optional password for the TURN server.
			}
		]
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remote_description_received.connect(_on_remote_description_received)
	ice_candidate_received.connect(_on_ice_candidate_received)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass

func _get_generic_peer_connection(id: int) -> WebRTCPeerConnection:
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	
	peer.initialize(_ice_servers)
	
	peer.session_description_created.connect(_on_session_description_created.bind(id))
	peer.ice_candidate_created.connect(_on_ice_candidate_created.bind(id))
	
	_rtc_mtp.add_peer(peer, id)
	return peer

func init_server():
	_rtc_mtp.create_server()
	multiplayer.multiplayer_peer = _rtc_mtp
	pass

func init_client():
	_rtc_mtp.create_client(LobbyLink.get_id())
	multiplayer.multiplayer_peer = _rtc_mtp
	var peer: WebRTCPeerConnection = _get_generic_peer_connection(1)
	peer.create_offer()
	pass

func add_remote_peer(webrtc_type: String, sdp: String, id: int):
	var peer: WebRTCPeerConnection = _get_generic_peer_connection(id)
	peer.set_remote_description(webrtc_type, sdp)
	pass

func _on_session_description_created(webrtc_type: String, sdp: String, id: int):
	_get_peer(id).set_local_description(webrtc_type, sdp)
	
	if LobbyLink.get_is_server():
		LobbyLink_WebSocketMessage.msg_send_answer(webrtc_type, sdp, id)
	else:
		LobbyLink_WebSocketMessage.msg_send_offer(webrtc_type, sdp)
	pass

func _on_remote_description_received(type: String, sdp: String, id: int):
	_get_peer(id).set_remote_description(type, sdp)
	pass

func _on_ice_candidate_created(media: String, index: int, ice_name: String, to: int):
	LobbyLink_WebSocketMessage.msg_send_candidate(media, index, ice_name, to)
	pass

func _on_ice_candidate_received(media: String, index: int, ice_name: String, id: int):
	_get_peer(id).add_ice_candidate(media, index, ice_name)
	pass

func _get_peer(id: int) -> WebRTCPeerConnection:
	return _rtc_mtp.get_peer(id).connection

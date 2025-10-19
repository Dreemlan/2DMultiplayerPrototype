# Handles emitting sounds to all peers
extends Node

const COMPONENT_AUDIO_EMIT = preload("uid://csk35ef5iffdj")


@rpc("authority", "call_remote", "reliable")
func emit_audio(audio_name, audio_pos) -> void:
	var inst: AudioStreamPlayer2D = COMPONENT_AUDIO_EMIT.instantiate()
	add_child(inst)
	
	var audio_path = "res://audio/" + audio_name
	inst.stream = load(audio_path)
	
	inst.global_position = audio_pos
	inst.play()

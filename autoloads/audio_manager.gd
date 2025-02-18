extends Node

var audio_clips: Array = []

var looping_audio_clips: Dictionary = {}

var current_music: AudioStreamPlayer = null

func _ready():
	OptionsManager.options_updated.connect(_update_volumes)
	_update_volumes()
	#create an audio player and give it our clip
	current_music = AudioStreamPlayer.new()
	current_music.bus = "Music"
	add_child(current_music)

func _process(_delta):
	for audio_player in audio_clips:
		if !audio_player.playing:
			audio_player.queue_free()
			audio_clips.erase(audio_player)

func _continue_audio(player: AudioStreamPlayer):
	player.stream_paused = false

func _play_clip(audio_clip: AudioStream, bus: String):
	#create an audio player and give it our clip
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	new_player.stream = audio_clip
	new_player.bus = bus
	add_child(new_player)
	#add it to our list to be able to free the node when done
	audio_clips.append(new_player)
	new_player.play()

func _play_clip_loop(audio_clip: AudioStream, bus: String, access_tag: String):
	#create an audio player and give it our clip
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	new_player.stream = audio_clip
	new_player.bus = bus
	new_player.finished.connect(_continue_audio.bind(new_player))
	add_child(new_player)
	#add it to our list to be able to free the node when done
	looping_audio_clips[access_tag] = new_player
	new_player.play()

func _stop_clip_loop(access_tag: String):
	looping_audio_clips[access_tag].queue_free()
	looping_audio_clips.erase(access_tag)

func _play_clip_batch(audio_clip_batch: Array, bus: String):
	for audio_clip in audio_clip_batch:
		_play_clip(audio_clip, bus)

func _play_random_clip(audio_clip_batch: Array, bus: String):
	_play_clip(audio_clip_batch.pick_random(), bus)

func _play_music(track: AudioStream):
	current_music.stream = track
	current_music.play()

func _stop_music():
	current_music.stream_paused = true

func _update_volumes():
	#Get the options setting for the volumes
	var master_volume = OptionsManager.options["Audio"]["Master Volume"]
	var music_volume = OptionsManager.options["Audio"]["Music Volume"]
	var sfx_volume = OptionsManager.options["Audio"]["SFX Volume"]
	var ui_volume = OptionsManager.options["Audio"]["UI Volume"]
	#Remap the setting onto the logmarithmic decible scale
	master_volume = remap(master_volume, 0, 1, -70, 0)
	music_volume = remap(music_volume, 0, 1, -70, 0)
	sfx_volume = remap(sfx_volume, 0, 1, -70, 0)
	ui_volume = remap(ui_volume, 0, 1, -70, 0)
	#set the buses to match the new volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), ui_volume)

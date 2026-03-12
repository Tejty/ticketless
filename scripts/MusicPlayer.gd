extends AudioStreamPlayer

@export var music: Array[AudioStream]
@export var winner: AudioStream
@export var died: AudioStream
@export var menu: AudioStream

var state: MusicState = MusicState.MENU
var drunk := false
var speed_multiplier := 1.0

enum MusicState {MENU, WON, LOST, GAME}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	play_next()

func _on_finished() -> void:
	play_next()

func play_next():
	match state:
		MusicState.MENU:
			stream = menu
		MusicState.WON:
			stream = winner
		MusicState.LOST:
			stream = died
		MusicState.GAME:
			stream = music.pick_random()
	play_selected()

func play_selected():
	play()

func _process(_delta: float) -> void:
	var time_left = stream.get_length() - get_playback_position()
	volume_linear = min(time_left / 20 + 0.25, 1)
	var target_pitch = (sin(Time.get_ticks_msec() * 0.03568) * 0.05 + 0.95 if drunk else 1.0) * speed_multiplier
	#if target_pitch != pitch_scale:
	pitch_scale = target_pitch

func _on_won(_cause: String):
	state = MusicState.WON
	play_next()

func _on_died(_cause: String):
	state = MusicState.LOST
	play_next()

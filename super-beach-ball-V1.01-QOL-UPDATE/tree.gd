extends Node
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var win_music_player: AudioStreamPlayer = $WinMusicPlayer
var playing_game_music = false

func _ready():
	Global.tree = self

func _physics_process(_delta: float) -> void:
	if Global.winning_side == 0:
		win_music_player.playing = false
		if playing_game_music and music_player.playing == false:
			music_player.playing = true
		elif not playing_game_music and music_player.playing == true:
			music_player.playing = false
	else:
		music_player.playing = false
		if playing_game_music and win_music_player.playing == false:
			win_music_player.playing = true
		elif not playing_game_music and win_music_player.playing == true:
			win_music_player.playing = false


func change_scene(new_scene_name : String):
	for n in self.get_children():
		if n != music_player and n != win_music_player:
			n.queue_free()
	var new_scene = load(new_scene_name)
	var new_scene_instance = new_scene.instantiate()
	add_child(new_scene_instance)
	if new_scene_name == "res://main.tscn" or new_scene_name == "res://pvp_main.tscn":
		playing_game_music = true
	else:
		playing_game_music = false
	
func dialogue(resource_string : String, title : String):
	var resource = load(resource_string)
	DialogueManager.show_dialogue_balloon(resource, title)


#Dialogue functions
func end_dialogue():
	await get_tree().create_timer(0.5).timeout
	Global.tut_explanation_active = false
	get_tree().paused = false

func delay_to_spike_tut():
	Global.tut_explanation_active = false
	get_tree().paused = false
	await get_tree().create_timer(0.7).timeout
	Global.tut_explanation_active = true
	var resource = load("res://Dialogue/SpikeTutorial.dialogue")
	Global.spiker_movement_testing = true
	DialogueManager.show_dialogue_balloon(resource, "SpikeTutorial")

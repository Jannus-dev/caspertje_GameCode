extends Node2D

#   ____   __    _  _  _  _  __  __  ___       ____  ____  _  _ 
#  (_  _) /__\  ( \( )( \( )(  )(  )/ __)     (  _ \( ___)( \/ )
# .-_)(  /(__)\  )  (  )  (  )(__)( \__ \ ___  )(_) ))__)  \  / 
# \____)(__)(__)(_)\_)(_)\_)(______)(___/(___)(____/(____)  \/  


# Alle variabele aanmaken en waarde geven:
#alle age stages dat het monster kan worden in deze lijst
enum AgeStage { BABY, KIND, PUBER, VOLWASSENE, BEJAARDE }

# max aantal stages voor dat caspertje dood gaat
@export var max_stage: int = 4  # 0=neutraal, 1-3 ziek, 4=dood

# random aantal secondes voor de timer die bepaald na hoe veel seconde caspertje een volgende levens fase heeft
var seconds_per_age: float = randf_range(7200, 14400) 

# random aantal secondes voor de timer die bepaald na hoe veel seconde caspertje nodig heeft om weer honger te krijgen
var hunger_tick_seconds: float = randf_range(20.0, 120.0) 

# random aantal secondes voor de timer die bepaald na hoe veel seconde caspertje een volgende levens fase heeft demo versie
#var seconds_per_age: float = 20.0   # Voor demo

# random aantal secondes voor de timer die bepaald na hoe veel seconde caspertje nodig heeft om weer honger te krijgen demo versie
#var hunger_tick_seconds: float = 10.0  # Voor demo

# variabele om op teslaan welke leeftijd het monstertje is
var current_age: AgeStage = AgeStage.BABY

# variabele om de level van honger bij te houden
var hunger_stage: int = 0

# variabele om de level van dorst bij te houden
var thirst_stage: int = 0

# variabele om bij te houden of het monster levend of dood is
var alive: bool = true

# 
var hunger_timer: float = 0.0

var age_timer: float = 0.0

var current_minute_key: String

var gave_drink_this_window: bool = false

var missed_drinks: int = 0   # tellen hoeveel keer gemist

var nausea_timer: float = 0.0

var nausea_active: bool = false

# referenties naar nodes

@onready var pet_sprite: Sprite2D = $PetSprite

@onready var age_label: Label = $AgeLabel

@onready var drink_label: Label = $DrinkLabel

@onready var message_label: Label = $MessageLabel

@onready var feed_button: TextureButton = $FeedButton

@onready var drink_button: TextureButton = $DrinkButton

@onready var feed_particles: CPUParticles2D = $FeedParticles

@onready var drink_particles: CPUParticles2D = $DrinkParticles

@onready var nausea_overlay: ColorRect = $NauseaOverlay

@onready var reset_button: TextureButton = $ResetButton


@onready var eat_sound: AudioStreamPlayer = $EatSound

@onready var drink_sound: AudioStreamPlayer = $DrinkSound

#-----------------------------------------#
# ALLE sprites (vul hier je bestanden in)
var sprites = {
	AgeStage.BABY: {
		"neutral": preload("res://art/baby/neutral.png"),
		"hungry": [
			preload("res://art/baby/hungry1.png"),
			preload("res://art/baby/hungry2.png"),
			preload("res://art/baby/hungry3.png"),
			preload("res://art/baby/hungry4.png")
		],
		"thirsty": [
			preload("res://art/baby/thirsty1.png"),
			preload("res://art/baby/thirsty2.png"),
			preload("res://art/baby/thirsty3.png"),
			preload("res://art/baby/thirsty4.png")
		],
		"both": [
			preload("res://art/baby/both1.png"),
			preload("res://art/baby/both2.png"),
			preload("res://art/baby/both3.png"),
			preload("res://art/baby/both4.png")
		]
	},
	AgeStage.KIND: {
		"neutral": preload("res://art/kind/neutral.png"),
		"hungry": [
			preload("res://art/kind/hungry1.png"),
			preload("res://art/kind/hungry2.png"),
			preload("res://art/kind/hungry3.png"),
			preload("res://art/kind/hungry4.png")
		],
		"thirsty": [
			preload("res://art/kind/thirsty1.png"),
			preload("res://art/kind/thirsty2.png"),
			preload("res://art/kind/thirsty3.png"),
			preload("res://art/kind/thirsty4.png")
		],
		"both": [
			preload("res://art/kind/both1.png"),
			preload("res://art/kind/both2.png"),
			preload("res://art/kind/both3.png"),
			preload("res://art/kind/both4.png")
		]
	},
	AgeStage.PUBER: {
		"neutral": preload("res://art/puber/neutral.png"),
		"hungry": [
			preload("res://art/puber/hungry1.png"),
			preload("res://art/puber/hungry2.png"),
			preload("res://art/puber/hungry3.png"),
			preload("res://art/puber/hungry4.png")
		],
		"thirsty": [
			preload("res://art/puber/thirsty1.png"),
			preload("res://art/puber/thirsty2.png"),
			preload("res://art/puber/thirsty3.png"),
			preload("res://art/puber/thirsty4.png")
		],
		"both": [
			preload("res://art/puber/both1.png"),
			preload("res://art/puber/both2.png"),
			preload("res://art/puber/both3.png"),
			preload("res://art/puber/both4.png")
		]
	},
	AgeStage.VOLWASSENE: {
		"neutral": preload("res://art/volwassene/neutral.png"),
		"hungry": [
			preload("res://art/volwassene/hungry1.png"),
			preload("res://art/volwassene/hungry2.png"),
			preload("res://art/volwassene/hungry3.png"),
			preload("res://art/volwassene/hungry4.png")
		],
		"thirsty": [
			preload("res://art/volwassene/thirsty1.png"),
			preload("res://art/volwassene/thirsty2.png"),
			preload("res://art/volwassene/thirsty3.png"),
			preload("res://art/volwassene/thirsty4.png")
		],
		"both": [
			preload("res://art/volwassene/both1.png"),
			preload("res://art/volwassene/both2.png"),
			preload("res://art/volwassene/both3.png"),
			preload("res://art/volwassene/both4.png")
		]
	},
	AgeStage.BEJAARDE: {
		"neutral": preload("res://art/bejaarde/neutral.png"),
		"hungry": [
			preload("res://art/bejaarde/hungry1.png"),
			preload("res://art/bejaarde/hungry2.png"),
			preload("res://art/bejaarde/hungry3.png"),
			preload("res://art/bejaarde/hungry4.png")
		],
		"thirsty": [
			preload("res://art/bejaarde/thirsty1.png"),
			preload("res://art/bejaarde/thirsty2.png"),
			preload("res://art/bejaarde/thirsty3.png"),
			preload("res://art/volwassene/thirsty4.png")
		],
		"both": [
			preload("res://art/bejaarde/both1.png"),
			preload("res://art/bejaarde/both2.png"),
			preload("res://art/bejaarde/both3.png"),
			preload("res://art/bejaarde/both4.png")
		]
	}
}

var drink_particle_textures = {
	AgeStage.BABY: preload("res://art/particles/milk.png"),
	AgeStage.KIND: preload("res://art/particles/limonade.png"),
	AgeStage.PUBER: preload("res://art/particles/cola.png"),
	AgeStage.VOLWASSENE: preload("res://art/particles/bier.png"),
	AgeStage.BEJAARDE: preload("res://art/particles/advocaat.png")
}
#-----------------------------------------#
func _ready():

	load_game()

	current_minute_key = _minute_key(Time.get_datetime_dict_from_system())

	update_ui()

	update_visual()

	feed_button.pressed.connect(_on_feed_pressed)

	drink_button.pressed.connect(_on_drink_pressed)

	#drink_button.pressed.connect(_on_reset_pressed)

	reset_button.pressed.connect(_on_reset_pressed)

	print_debug("seconds_per_age")

	print_debug(seconds_per_age)

	print_debug("hunger_tick_seconds")

	print_debug(hunger_tick_seconds)

	feed_particles.emitting = false

	reset_button.visible = false
	
func _notification(what):

	if what == NOTIFICATION_WM_CLOSE_REQUEST \

	or what == NOTIFICATION_APPLICATION_PAUSED \

	or what == NOTIFICATION_APPLICATION_FOCUS_OUT:

		save_game()

		print_debug("Saving game to user://savegame.json")

func _process(delta):

	if not alive: return

	# leeftijd

	age_timer += delta

	if age_timer >= seconds_per_age:

		age_timer = 0.0

		advance_age()


	# honger

	hunger_timer += delta

	if hunger_timer >= hunger_tick_seconds:

		hunger_timer = 0.0

		if hunger_stage < max_stage:

			hunger_stage += 1


	# check dood

	if hunger_stage == max_stage or thirst_stage == max_stage:

		die()

		return

		
	if nausea_active:

		nausea_timer -= delta

		var mat := nausea_overlay.material as ShaderMaterial

		if mat:

			mat.set_shader_parameter("strength", 10.0) # of iets met lerp

		if nausea_timer <= 0:

			nausea_overlay.visible = false

			nausea_active = false


	# drinkmoment check

	var now = Time.get_datetime_dict_from_system()

	var minute_key = _minute_key(now)

	if minute_key != current_minute_key:

		if _is_drink_window(_parse_minute_key(current_minute_key)) and not gave_drink_this_window:

			if thirst_stage < max_stage:

				thirst_stage += 1

		gave_drink_this_window = false

		current_minute_key = minute_key


	# knoppen

	drink_button.disabled = not alive

	feed_button.disabled = not alive
 

	update_ui()

	update_visual()
	
	var autosave_timer := 0.0
	
	autosave_timer += delta

	if autosave_timer > 30.0: # elke 30s

		save_game()

		autosave_timer = 0.0

# --- ACTIES ---
func _on_feed_pressed():

	if not alive: return

	hunger_stage = 0

	message_label.text = "Nom nom!"

	update_visual()

	eat_sound.play() # eetgeluiden

	# particles afvuren

	feed_particles.emitting = true

	# optioneel: automatisch weer stoppen na 1 seconde

	await get_tree().create_timer(1.0).timeout

	feed_particles.emitting = false

	hunger_tick_seconds = randf_range(20.0, 120.0) # random nieuwe honger tijd

	print_debug("hunger_tick_seconds")

	print_debug(hunger_tick_seconds)

func _on_drink_pressed():

	if not alive:

		return

	if not _is_drink_window(Time.get_datetime_dict_from_system()):

		message_label.text = "Geen drinkmoment nu."

		_trigger_nausea_effect()

		return

	# deze blok alleen doen als het nog niet gebeurd is

	if not gave_drink_this_window:

		gave_drink_this_window = true

		thirst_stage = 0

		message_label.text = "Slurp!"

		update_visual()


	# ↓↓↓ particle effect ALTIJD doen, ook als gave_drink_this_window al true is ↓↓↓

	var tex = drink_particle_textures.get(current_age, null)

	if tex:

		drink_particles.texture = tex

		drink_particles.restart()      # heel belangrijk

		drink_particles.emitting = true

		drink_sound.play() # drink geluiden

func _trigger_nausea_effect():

	nausea_overlay.visible = true

	nausea_timer = 3.0  # 3 seconden

	nausea_active = true

func advance_age():

	if current_age == AgeStage.BEJAARDE: return

	current_age += 1

	message_label.text = "Nieuwe levensfase!"

	update_visual()

	#seconds_per_age = randf_range(10800, 21600)

	print_debug("seconds_per_age")

	print_debug(seconds_per_age)

func die():
	alive = false
	message_label.text = "Je monster is overleden..."
	feed_button.disabled = true
	drink_button.disabled = true
	reset_button.visible = true
	update_visual()
	

# --- VISUALS ---
func update_ui():
	age_label.text = "Leeftijd: %s" % _age_to_string(current_age)
	drink_label.text = "Drank: %s" % _drink_for_age(current_age)

func update_visual():
	var set = sprites.get(current_age, null)
	if not set: return

	if not alive:
		# doodsoorzaak
		if hunger_stage == max_stage and thirst_stage == max_stage:
			pet_sprite.texture = set["both"][max_stage - 1]
		elif hunger_stage == max_stage:
			pet_sprite.texture = set["hungry"][max_stage - 1]
		elif thirst_stage == max_stage:
			pet_sprite.texture = set["thirsty"][max_stage - 1]
		return

	# levend
	if hunger_stage == 0 and thirst_stage == 0:
		pet_sprite.texture = set["neutral"]
	elif hunger_stage > 0 and thirst_stage > 0:
		var idx = clamp(max(hunger_stage, thirst_stage) - 1, 0, max_stage - 1)
		pet_sprite.texture = set["both"][idx]
	elif hunger_stage > 0:
		var idx = clamp(hunger_stage - 1, 0, max_stage - 1)
		pet_sprite.texture = set["hungry"][idx]
	elif thirst_stage > 0:
		var idx = clamp(thirst_stage - 1, 0, max_stage - 1)
		pet_sprite.texture = set["thirsty"][idx]
	else:
		pet_sprite.texture = set["neutral"]

# --- HELPERS ---
func _drink_for_age(age: AgeStage) -> String:
	match age:
		AgeStage.BABY: return "Melk"
		AgeStage.KIND: return "Limonade"
		AgeStage.PUBER: return "Cola"
		AgeStage.VOLWASSENE: return "Bier"
		AgeStage.BEJAARDE: return "Advocaat"
		_: return ""

func _age_to_string(age: AgeStage) -> String:
	match age:
		AgeStage.BABY: return "Baby"
		AgeStage.KIND: return "Kind"
		AgeStage.PUBER: return "Puber"
		AgeStage.VOLWASSENE: return "Volwassene"
		AgeStage.BEJAARDE: return "Bejaarde"
		_: return "?"

func _is_drink_window(dt: Dictionary) -> bool:
	var hhmm = "%02d%02d" % [dt["hour"], dt["minute"]]
	return "5" in hhmm


func _minute_key(dt: Dictionary) -> String:
	return "%04d%02d%02d%02d%02d" % [dt["year"], dt["month"], dt["day"], dt["hour"], dt["minute"]]

func _parse_minute_key(key: String) -> Dictionary:
	# simplificatie
	return Time.get_datetime_dict_from_system()
	
func save_game():
	var data = {
		"current_age": current_age,
		"hunger_stage": hunger_stage,
		"thirst_stage": thirst_stage,
		"alive": alive,
		"age_timer": age_timer,
		"hunger_timer": hunger_timer,
		"current_minute_key": current_minute_key,
		"gave_drink_this_window": gave_drink_this_window,
		"missed_drinks": missed_drinks,
		"seconds_per_age": seconds_per_age,
		"hunger_tick_seconds": hunger_tick_seconds
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_game():
	if not FileAccess.file_exists("user://savegame.json"):
		print_debug("No savegame found.")
		return
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if typeof(result) == TYPE_DICTIONARY:
			var data = result
			current_age = data.get("current_age", AgeStage.BABY)
			hunger_stage = data.get("hunger_stage", 0)
			thirst_stage = data.get("thirst_stage", 0)
			alive = data.get("alive", true)
			age_timer = data.get("age_timer", 0.0)
			hunger_timer = data.get("hunger_timer", 0.0)
			current_minute_key = data.get("current_minute_key", _minute_key(Time.get_datetime_dict_from_system()))
			gave_drink_this_window = data.get("gave_drink_this_window", false)
			missed_drinks = data.get("missed_drinks", 0)
			seconds_per_age = data.get("seconds_per_age", seconds_per_age)
			hunger_tick_seconds = data.get("hunger_tick_seconds", hunger_tick_seconds)

func _on_reset_pressed():
	# verwijder oude savefile
	if FileAccess.file_exists("user://savegame.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://savegame.json"))
	# reset alle state
	current_age = AgeStage.BABY
	hunger_stage = 0
	thirst_stage = 0
	alive = true
	age_timer = 0.0
	hunger_timer = 0.0
	seconds_per_age = randf_range(7200.0, 14400.0) 
	hunger_tick_seconds = randf_range(20.0, 120.0) # nieuwe honger timer
	#seconds_per_age = 20.0 # voor demo
	#hunger_tick_seconds = 10.0 # voor demo

	# UI terugzetten
	feed_button.disabled = false
	drink_button.disabled = false
	reset_button.visible = false
	message_label.text = "Een nieuw monstertje!"
	update_ui()
	update_visual()

	# meteen opslaan
	save_game()

extends Resource
class_name RuneManager

## RuneData would be smthg that holds info for each specific rune

## RuneManager holds all RuneDatas (in an array) and has the functions for them

## this is DIFFERENT from room_preset.gd

## ok fuck it id rather have RuneData as its own thing

@export var runes_data_array: Array[RuneData]


## since theres only 4 runes with 99% identical functionality (increase a stat),
## the "rune" is just stored as a RuneType variable in the chest

## NOTE: the way im doing probability
## is that the first items are rolled
## before the last ones are rolled
## gonna shuffle for now to make it less biased
func pick_random_rune() -> RuneData:
	var pity: float = 0
	var total_chance: float = 0
	var picked_rune: RuneData = runes_data_array[0]
	
	for rune in runes_data_array:
		total_chance += rune.chance
	
	runes_data_array.shuffle()
	
	for rune in runes_data_array:
		var rune_probability: float = rune.chance/total_chance
		var final_probability: float = rune_probability + pity
		#print("%d: final_probability: %0.4f" % [rune.type, final_probability])
		if RNG.roll_probability(final_probability):
			picked_rune = rune
			#print("selected")
			break
		pity += rune_probability
	return picked_rune

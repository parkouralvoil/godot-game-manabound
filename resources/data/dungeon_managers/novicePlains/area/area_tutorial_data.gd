extends AreaData
class_name AreaTutorialData

func update_available_presets(current_lvl: int) -> Array[RoomPreset]:
	var next_room: int = current_lvl + 1 ## available presets is for the next room
	#print_debug("tutorial current lvl: %d" % current_lvl)
	assert(EasyPresets.size() == 3)
	if next_room == 2:
		return [EasyPresets[1]]
	elif next_room == 3:
		EventBus.tutorial_team_restriction_set.emit(2)
		return [EasyPresets[2]]
	elif next_room == rest_lvl:
		EventBus.tutorial_team_restriction_set.emit(3)
		return RestPresets
	else:
		return BossPreset ## last level, needs to be here to tell dungeon_data "last level"

func shuffle_room_array() -> void:
	pass


func get_normal_room() -> PackedScene:
	print_debug("this shouldnt be called")
	return null

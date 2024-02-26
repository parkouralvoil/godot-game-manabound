extends CanvasLayer

# a: for basic attack upgrades
# b: for ultimate upgrades
# c: for other upgrades

@export var skill_a1: SkillNode
@export var skill_a2: SkillNode
@export var skill_b1: SkillNode
@export var skill_b2: SkillNode
var skill_array: Array[SkillNode] = [skill_a1, skill_a2, skill_b1, skill_b2]

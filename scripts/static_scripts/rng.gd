extends Object
class_name RNG

static var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

static func roll_probability(success_chance: float) -> bool:
	var probability: float = _rng.randf()
	return probability <= success_chance ## true if probability is <= success


static func random_float(from: float, to: float) -> float:
	return _rng.randf_range(from, to)

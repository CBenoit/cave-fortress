var value = 0
var _discontentment_exponent

func _init(discontentment_exponent):
	_discontentment_exponent = discontentment_exponent

func get_discontentment(new_value):
	# calling pow on a negative value is quite risky.
	if new_value < 0:
		new_value = 0
	return pow(new_value, _discontentment_exponent)

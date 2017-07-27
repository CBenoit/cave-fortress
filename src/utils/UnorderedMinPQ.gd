var _array = []
var _comparator_less

func _init(comparator_less):
	_comparator_less = comparator_less

func empty():
	return _array.empty()

func size():
	return _array.size()

func insert(elem):
	_array.append(elem)

func pop_min():
	var mini = 0
	for i in range(1, _array.size()):
		if (_comparator_less.call_func(_array[i], _array[mini])):
			mini = i

	var temp = _array[mini]
	_array[mini] = _array[_array.size() - 1]
	_array.pop_back()

	return temp;

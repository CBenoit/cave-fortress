var _array = []
var _comparator_less

func _init(comparator_less):
	_comparator_less = comparator_less
	_array.append(null) # first index not used for simplicity

func empty():
	return _array.size() == 1

func size():
	return _array.size() - 1

func insert(elem):
	_array.append(elem)
	_swim(size())

func pop_min():
	var mini = _array[1]
	_array[1] = _array[size()]
	_array.pop_back()
	_sink(1)

	return mini;

func _swim(i):
   while i > 1 and _comparator_less.call_func(_array[i], _array[i/2]):
      _exch(i, i/2)
      i = i/2

func _sink(i):
	var N = size()
	while 2*i <= N:
		var j = 2*i
		if j < N and _comparator_less.call_func(_array[j+1], _array[j]):
			j += 1
		if not _comparator_less.call_func(_array[j], _array[i]):
			break
		_exch(i, j)
		i = j

func _exch(i, j):
	var temp = _array[i]
	_array[i] = _array[j]
	_array[j] = temp

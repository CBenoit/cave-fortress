extends Sprite

var m_max_tile_health
var m_current_tile_health

func init(max_tile_health, current_tile_health):
	m_max_tile_health = max_tile_health
	set_tile_health(current_tile_health)

func set_max_tile_health(value):
	m_max_tile_health = value
	if m_current_tile_health >= m_max_tile_health:
		queue_free()
		print("[WARNING] if the tile is full life, no need to have fissures!")

func decrease_tile_health(value):
	set_tile_health(m_current_tile_health - value)

func set_tile_health(value):
	m_current_tile_health = value
	if m_current_tile_health >= m_max_tile_health or m_current_tile_health <= 0:
		queue_free()
		if m_current_tile_health >= m_max_tile_health:
			print("[WARNING] if the tile is full life, no need to have fissures!")
	else:
		_update_frame()

func get_tile_health():
	return m_current_tile_health

func _update_frame():
	set_frame(floor(float(m_max_tile_health - m_current_tile_health) * get_hframes() / m_max_tile_health))

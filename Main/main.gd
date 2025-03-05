extends Node2D


@export var brushSize = 3

const emptyID := -1
const waterID := 0
const oilID := 1
const lavaID := 2
const rockID := 3
const woodID := 4
const sandID := 5
const gunpowderID := 6
const fireID := 7
const smokeID := 8
const explosionID := 9

const size_x = 288
const size_y = 162

var sand_gravity = 3
var water_gravity = 3
var oil_gravity = 2
var dispertion_rate = 3

var currentBrush = 3

var rng = RandomNumberGenerator.new()

@onready var tileSet = $TileMap


func _ready():
	
	var cells = tileSet.get_used_cells(0)
	cells.sort_custom(compare_vector2i_y_desc)

func _physics_process(delta):
	loop_tile_set()

func loop_tile_set():
	
	var cells = tileSet.get_used_cells(0)
	cells.sort_custom(compare_vector2i_y_desc)
	
	for cell in cells:
		
		var cellIndex = tileSet.get_cell_source_id(0, cell)
		
		match cellIndex:
			
			sandID:
				
				var down = Vector2i(cell.x, cell.y + 1)
				var down_left = Vector2i(cell.x - 1, cell.y + 1)
				var down_right = Vector2i(cell.x + 1, cell.y + 1)
				
				if (tileSet.get_cell_source_id(0, down) == emptyID):
					
					move_cell(cell, 0, check_limit_down(cell, sand_gravity), sandID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, down) == sandID):
					
					moveable_solid_behaviour(cell, down_left, down_right, sandID)
						
				elif (tileSet.get_cell_source_id(0, down) == rockID):
					
					moveable_solid_behaviour(cell, down_left, down_right, sandID)
					
				elif (tileSet.get_cell_source_id(0, down) == woodID):
					
					moveable_solid_behaviour(cell, down_left, down_right, sandID)
					
				elif (tileSet.get_cell_source_id(0, down) == gunpowderID):
					
					moveable_solid_behaviour(cell, down_left, down_right, sandID)
				
				elif (tileSet.get_cell_source_id(0, down) == waterID):
					
					swap_cells(cell, 0, check_limit_down(cell, sand_gravity), sandID, waterID, rng.randi_range(0, 3), 0)
					
				elif (tileSet.get_cell_source_id(0, down) == fireID):
					
					swap_cells(cell, 0, 1, sandID, smokeID, rng.randi_range(0, 3), 0)
					
				elif (tileSet.get_cell_source_id(0, down) == oilID):
					
					swap_cells(cell, 0, check_limit_down(cell, sand_gravity), sandID, oilID, rng.randi_range(0, 3), 0)
					
			waterID:
				
				var chance = rng.randi_range(0, 300)
				
				var down = Vector2i(cell.x, cell.y + 1)
				var left = Vector2i(cell.x - 1, cell.y)
				var right = Vector2i(cell.x + 1, cell.y)
				var down_left = Vector2i(cell.x - 1, cell.y + 1)
				var down_right = Vector2i(cell.x + 1, cell.y + 1)
				
				if (tileSet.get_cell_source_id(0, down) == emptyID):
					
					move_cell(cell, 0, check_limit_down(cell, water_gravity), waterID, 0)
					
				elif (tileSet.get_cell_source_id(0, down) == sandID):
					
					liquid_behaviour(cell, left, right, down_left, down_right, waterID, 1)
						
				elif (tileSet.get_cell_source_id(0, down) == waterID):
					
					liquid_behaviour(cell, left, right, down_left, down_right, waterID, dispertion_rate)
					water_in_oil_behaviour(cell, left, right, down_left, down_right, waterID)
					
				elif (tileSet.get_cell_source_id(0, down) == rockID):
					
					liquid_behaviour(cell, left, right, down_left, down_right, waterID, dispertion_rate)
				
				elif (tileSet.get_cell_source_id(0, down) == woodID):
					
					liquid_behaviour(cell, left, right, down_left, down_right, waterID, dispertion_rate)
				
				elif (tileSet.get_cell_source_id(0, down) == fireID):
					
					if (chance < 100): swap_cells(cell, 0, 1, smokeID, smokeID, rng.randi_range(0, 3), rng.randi_range(0, 3))
					else: swap_cells(cell, 0, 1, smokeID, waterID, rng.randi_range(0, 3), 0)
					
				elif (tileSet.get_cell_source_id(0, down) == oilID):
					
					swap_cells(cell, 0, 1, waterID, oilID, 0, 0)
					
			fireID:
				
				var chance = rng.randi_range(0, 300)
				
				if chance == 150: remove_cell(cell)
				
				var down = Vector2i(cell.x, cell.y + 1)
				var down_left = Vector2i(cell.x - 1, cell.y + 1)
				var down_right = Vector2i(cell.x + 1, cell.y + 1)
				var up = Vector2i(cell.x, cell.y - 1)
				var left = Vector2i(cell.x - 1, cell.y)
				var right = Vector2i(cell.x + 1, cell.y)
				var up_left = Vector2i(cell.x - 1, cell.y - 1)
				var up_right = Vector2i(cell.x + 1, cell.y - 1)
				
				if (tileSet.get_cell_source_id(0, up) == woodID or tileSet.get_cell_source_id(0, left) == woodID or tileSet.get_cell_source_id(0, right) == woodID or tileSet.get_cell_source_id(0, down) == woodID):
					
					if chance < 8:
					
						if (tileSet.get_cell_source_id(0, down) == woodID and chance == 0): spread_cell(cell, 0, 1, fireID, rng.randi_range(0, 3))
						if (tileSet.get_cell_source_id(0, up) == woodID and chance <= 1): spread_cell(cell, 0, -1, fireID, rng.randi_range(0, 3))
						if (tileSet.get_cell_source_id(0, left) == woodID and chance == 2): spread_cell(cell, -1, 0, fireID, rng.randi_range(0, 3))
						if (tileSet.get_cell_source_id(0, right) == woodID and chance == 3): spread_cell(cell, 1, 0, fireID, rng.randi_range(0, 3))
						if (tileSet.get_cell_source_id(0, down_left) == woodID and chance == 4): spread_cell(cell, -1, 1, fireID, rng.randi_range(0, 3))
						if (tileSet.get_cell_source_id(0, down_right) == woodID and chance == 5): spread_cell(cell, 1, 1, fireID, rng.randi_range(0, 3))
						if (tileSet.get_cell_source_id(0, up_left) == woodID and chance <= 4): spread_cell(cell, -1, -1, fireID, rng.randi_range(0, 3))
						if (tileSet.get_cell_source_id(0, up_right) == woodID and chance <= 4): spread_cell(cell, 1, -1, fireID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, up) == oilID or tileSet.get_cell_source_id(0, left) == oilID or tileSet.get_cell_source_id(0, right) == oilID or tileSet.get_cell_source_id(0, down) == oilID):
					
					if chance < 100:
						spread_cell(cell, 0, 1, fireID, rng.randi_range(0, 3))
						spread_cell(cell, 1, 0, fireID, rng.randi_range(0, 3))
						spread_cell(cell, -1, 0, fireID, rng.randi_range(0, 3))
						spread_cell(cell, 0, -1, fireID, rng.randi_range(0, 3))
				
				elif (tileSet.get_cell_source_id(0, up) == gunpowderID or tileSet.get_cell_source_id(0, left) == gunpowderID or tileSet.get_cell_source_id(0, right) == gunpowderID or tileSet.get_cell_source_id(0, down) == gunpowderID):
					
					var radius = rng.randi_range(8, 25)
					
					for x in range (-radius, radius + 1):
						for y in range (-radius, radius + 1):
							
							if Vector2(x, y).length() <= radius:
								spread_cell(cell, x, y, explosionID, rng.randi_range(0, 3))
				
				elif (tileSet.get_cell_source_id(0, down) == emptyID) and chance < 100:
					
					move_cell(cell, 0, 1, fireID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, down) == fireID):
					
					if(chance < 295):
					
						if (tileSet.get_cell_source_id(0, down_left) == emptyID):
							
							move_cell(cell, -1, 1, fireID, rng.randi_range(0, 3))
							
						elif (tileSet.get_cell_source_id(0, down_right) == emptyID):
							
							move_cell(cell, 1, 1, fireID, rng.randi_range(0, 3))
							
					else: transform_cell(cell, smokeID, rng.randi_range(0, 3))
						
				elif (tileSet.get_cell_source_id(0, down) == sandID):
					
					if(chance < 35): transform_cell(cell, smokeID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, down) == waterID):
					
					if (chance < 100): swap_cells(cell, 0, 1, smokeID, smokeID, rng.randi_range(0, 3), rng.randi_range(0, 3))
					else: transform_cell(cell, smokeID, rng.randi_range(0, 3))
				
				elif (tileSet.get_cell_source_id(0, up) == emptyID) and chance > 240:
					
					if chance > 240 and chance <= 290: move_cell(cell, 0, -1, fireID, rng.randi_range(0, 3))
					if (chance > 295): swap_cells(cell, 0, -1, smokeID, fireID, rng.randi_range(0, 3), rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, left) == emptyID) and chance > 220 and chance <= 230:
					
					move_cell(cell, -1, 0, fireID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, right) == emptyID) and chance > 230 and chance <= 240:
					
					move_cell(cell, 1, 0, fireID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, down) == lavaID):
					
					move_cell(cell, 0, -1, fireID, rng.randi_range(0, 3))
					
			smokeID:
				
				var up = Vector2i(cell.x, cell.y - 1)
				var left = Vector2i(cell.x - 1, cell.y)
				var right = Vector2i(cell.x + 1, cell.y)
				var up_left = Vector2i(cell.x - 1, cell.y - 1)
				var up_right = Vector2i(cell.x + 1, cell.y - 1)
				
				if (tileSet.get_cell_source_id(0, up) == emptyID):
					
					move_cell(cell, 0, -1, smokeID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, up) == smokeID):
					
					gas_behaviour(cell, left, right, up_left, up_right, smokeID, 1)
					
				elif (tileSet.get_cell_source_id(0, up) == woodID):
					
					gas_behaviour(cell, left, right, up_left, up_right, smokeID, 1)
					
				elif (tileSet.get_cell_source_id(0, up) == rockID):
					
					gas_behaviour(cell, left, right, up_left, up_right, smokeID, 1)
					
				elif (tileSet.get_cell_source_id(0, up) == sandID):
					
					swap_cells(cell, 0, -1, smokeID, sandID, rng.randi_range(0, 3), rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, up) == gunpowderID):
					
					swap_cells(cell, 0, -1, smokeID, gunpowderID, rng.randi_range(0, 3), rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, up) == fireID):
					
					swap_cells(cell, 0, -1, smokeID, fireID, rng.randi_range(0, 3), rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, up) == waterID):
					
					swap_cells(cell, 0, -1, smokeID, waterID, rng.randi_range(0, 3), 0)
				
				elif (tileSet.get_cell_source_id(0, up) == oilID):
					
					swap_cells(cell, 0, -1, smokeID, oilID, rng.randi_range(0, 3), 0)
				
				elif (tileSet.get_cell_source_id(0, up) == lavaID):
					
					swap_cells(cell, 0, -1, smokeID, lavaID, rng.randi_range(0, 3), 0)
				
			gunpowderID:
				
				var down = Vector2i(cell.x, cell.y + 1)
				var down_left = Vector2i(cell.x - 1, cell.y + 1)
				var down_right = Vector2i(cell.x + 1, cell.y + 1)
				
				if (tileSet.get_cell_source_id(0, down) == emptyID):
					
					move_cell(cell, 0, check_limit_down(cell, sand_gravity), gunpowderID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, down) == sandID):
					
					moveable_solid_behaviour(cell, down_left, down_right, gunpowderID)
					
				elif (tileSet.get_cell_source_id(0, down) == gunpowderID):
					
					moveable_solid_behaviour(cell, down_left, down_right, gunpowderID)
				
				elif (tileSet.get_cell_source_id(0, down) == rockID):
					
					moveable_solid_behaviour(cell, down_left, down_right, gunpowderID)
					
				elif (tileSet.get_cell_source_id(0, down) == woodID):
					
					moveable_solid_behaviour(cell, down_left, down_right, gunpowderID)
				
				elif (tileSet.get_cell_source_id(0, down) == waterID):
					
					swap_cells(cell, 0, check_limit_down(cell, sand_gravity), gunpowderID, waterID, rng.randi_range(0, 3), 0)
					
				elif (tileSet.get_cell_source_id(0, down) == oilID):
					
					swap_cells(cell, 0, check_limit_down(cell, 1), gunpowderID, oilID, rng.randi_range(0, 3), 0)
					
			oilID:
				
				var down = Vector2i(cell.x, cell.y + 1)
				var down_left = Vector2i(cell.x - 1, cell.y + 1)
				var down_right = Vector2i(cell.x + 1, cell.y + 1)
				var left = Vector2i(cell.x - 1, cell.y)
				var right = Vector2i(cell.x + 1, cell.y)
				
				if (tileSet.get_cell_source_id(0, down) == emptyID):
					
					move_cell(cell, 0, check_limit_down(cell, oil_gravity), oilID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, down) == oilID):
					
					liquid_behaviour(cell, left, right, down_left, down_right, oilID, 1)
				
				elif (tileSet.get_cell_source_id(0, down) == rockID):
					
					liquid_behaviour(cell, left, right, down_left, down_right, oilID, 1)
					
				elif (tileSet.get_cell_source_id(0, down) == woodID):
					
					liquid_behaviour(cell, left, right, down_left, down_right, oilID, 1)
				
				elif (tileSet.get_cell_source_id(0, down) == waterID):
					
					liquid_behaviour(cell, left, right, down_left, down_right, oilID, 1)

				elif (tileSet.get_cell_source_id(0, down) == gunpowderID):
					
					liquid_behaviour(cell, left, right, down_left, down_right, oilID, 1)

			explosionID:
				
				var chance = rng.randi_range(0, 300)
				
				if chance < 10:
					
					transform_cell(cell, fireID, rng.randi_range(0, 3))
					
				elif chance > 10 and chance < 80:
					
					remove_cell(cell)
					
			lavaID:
				
				var chance = rng.randi_range(0, 300)
				
				var down = Vector2i(cell.x, cell.y + 1)
				var down_left = Vector2i(cell.x - 1, cell.y + 1)
				var down_right = Vector2i(cell.x + 1, cell.y + 1)
				var up = Vector2i(cell.x, cell.y - 1)
				var left = Vector2i(cell.x - 1, cell.y)
				var right = Vector2i(cell.x + 1, cell.y)
				var up_left = Vector2i(cell.x - 1, cell.y - 1)
				var up_right = Vector2i(cell.x + 1, cell.y - 1)
				
				if (tileSet.get_cell_source_id(0, up) == woodID or tileSet.get_cell_source_id(0, left) == woodID or tileSet.get_cell_source_id(0, right) == woodID or tileSet.get_cell_source_id(0, down) == woodID):
					
					if (tileSet.get_cell_source_id(0, left) == woodID): spread_cell(cell, -1, 0, fireID, rng.randi_range(0, 3))
					if (tileSet.get_cell_source_id(0, right) == woodID): spread_cell(cell, 1, 0, fireID, rng.randi_range(0, 3))
					if (tileSet.get_cell_source_id(0, down) == woodID): spread_cell(cell, 0, 1, fireID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, up) == oilID or tileSet.get_cell_source_id(0, left) == oilID or tileSet.get_cell_source_id(0, right) == oilID or tileSet.get_cell_source_id(0, down) == oilID):
					
					if (tileSet.get_cell_source_id(0, left) == oilID): spread_cell(cell, -1, 0, fireID, rng.randi_range(0, 3))
					if (tileSet.get_cell_source_id(0, right) == oilID): spread_cell(cell, 1, 0, fireID, rng.randi_range(0, 3))
					if (tileSet.get_cell_source_id(0, down) == oilID): spread_cell(cell, 0, 1, fireID, rng.randi_range(0, 3))
					if (tileSet.get_cell_source_id(0, up) == oilID): spread_cell(cell, 0, -1, fireID, rng.randi_range(0, 3))
				
				elif (tileSet.get_cell_source_id(0, up) == gunpowderID or tileSet.get_cell_source_id(0, left) == gunpowderID or tileSet.get_cell_source_id(0, right) == gunpowderID or tileSet.get_cell_source_id(0, down) == gunpowderID):
					
					var radius = rng.randi_range(8, 25)
					
					for x in range (-radius, radius + 1):
						for y in range (-radius, radius + 1):
							
							if Vector2(x, y).length() <= radius:
								spread_cell(cell, x, y, explosionID, rng.randi_range(0, 3))
				
				elif (tileSet.get_cell_source_id(0, up) == waterID or tileSet.get_cell_source_id(0, left) == waterID or tileSet.get_cell_source_id(0, right) == waterID or tileSet.get_cell_source_id(0, down) == waterID):
					
					if (tileSet.get_cell_source_id(0, left) == waterID): swap_cells(cell, -1, 0, rockID, rockID, 0, 0)
					elif (tileSet.get_cell_source_id(0, right) == waterID): swap_cells(cell, 1, 0, rockID, rockID, 0, 0)
					elif (tileSet.get_cell_source_id(0, up) == waterID): swap_cells(cell, 0, -1, rockID, rockID, 0, 0)
					elif (tileSet.get_cell_source_id(0, down) == waterID): swap_cells(cell, 0, 1, rockID, rockID, 0, 0)
				
				elif (tileSet.get_cell_source_id(0, down) == emptyID):
					
					move_cell(cell, 0, check_limit_down(cell, 1), lavaID, 0)
					
				elif (tileSet.get_cell_source_id(0, down) == lavaID and chance < 100):
					
					liquid_behaviour(cell, left, right, down_left, down_right, lavaID, 1)
					
				elif (tileSet.get_cell_source_id(0, up) == emptyID and chance == 100):
					
					spread_cell(cell, 0, -1, fireID, rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, down) == rockID) and chance < 100:
					
					liquid_behaviour(cell, left, right, down_left, down_right, lavaID, 1)
					
				elif (tileSet.get_cell_source_id(0, down) == sandID) and chance > 280:
					
					if chance < 295: swap_cells(cell, 0, 1, lavaID, smokeID, 0, rng.randi_range(0, 3))
					if chance >= 295: swap_cells(cell, 0, 1, smokeID, smokeID, rng.randi_range(0, 3), rng.randi_range(0, 3))
					
				elif (tileSet.get_cell_source_id(0, up) == sandID) and chance > 280:
					
					if chance < 295: swap_cells(cell, 0, -1, lavaID, smokeID, 0, rng.randi_range(0, 3))
					if chance >= 295: swap_cells(cell, 0, -1, smokeID, smokeID, rng.randi_range(0, 3), rng.randi_range(0, 3))



func is_empty(x, y):
	if (tileSet.get_cell_source_id(0, Vector2i(x, y)) == -1):
		return true
	else:
		return false

func compare_vector2i_y_desc(a: Vector2i, b: Vector2i) -> bool:
	return a.y > b.y


func move_cell(cell: Vector2i, limit_x: int, limit_y: int, ID: int, texture: int):
	
	tileSet.set_cell(0, cell, emptyID)
	tileSet.set_cell(0, Vector2i(cell.x + limit_x, cell.y + limit_y), ID, Vector2i(texture, 0))
	
func swap_cells(cell: Vector2i, limit_x: int, limit_y: int, new_cell_ID: int, curr_cell_ID: int, new_texture: int, curr_texture: int):
	
	tileSet.set_cell(0, cell, curr_cell_ID, Vector2i(curr_texture, 0))
	tileSet.set_cell(0, Vector2i(cell.x + limit_x, cell.y + limit_y), new_cell_ID, Vector2i(new_texture, 0))
	
func remove_cell(cell: Vector2i):
	
	tileSet.set_cell(0, cell, emptyID)
	
func transform_cell(cell: Vector2i, ID: int, texture: int):
	
	tileSet.set_cell(0, cell, ID, Vector2i(texture, 0))

func spread_cell(cell: Vector2i, limit_x: int, limit_y: int, ID: int, texture: int):
	
	tileSet.set_cell(0, Vector2i(cell.x + limit_x, cell.y + limit_y), ID, Vector2i(texture, 0))


func check_limit_right(cell, max_value):
	
	var limit = max_value
		
	for i in range(2, max_value + 1):
			
		if(tileSet.get_cell_source_id(0, Vector2i(cell.x + i, cell.y)) != emptyID):
				
			limit = i - 1
			break
				
	return limit
	
func check_limit_left(cell, max_value):
	
	var limit = max_value
		
	for i in range(2, max_value + 1):
			
		if(tileSet.get_cell_source_id(0, Vector2i(cell.x - i, cell.y)) != emptyID):
				
			limit = i - 1
			break
				
	return limit
	
func check_limit_down(cell, max_value):
	
	var limit = max_value
		
	for i in range(2, max_value + 1):
			
		if(tileSet.get_cell_source_id(0, Vector2i(cell.x, cell.y + i)) != emptyID):
				
			limit = i - 1
			break
				
	return limit
	
func check_limit_down_left(cell, max_value):
	
	var limit = max_value
		
	for i in range(2, max_value + 1):
			
		if(tileSet.get_cell_source_id(0, Vector2i(cell.x - i, cell.y + i)) != emptyID):
				
			limit = i - 1
			break
				
	return limit
	
func check_limit_down_right(cell, max_value):
	
	var limit = max_value
		
	for i in range(2, max_value + 1):
			
		if(tileSet.get_cell_source_id(0, Vector2i(cell.x + i, cell.y + i)) != emptyID):
				
			limit = i - 1
			break
	
	return limit

func check_limit_up_left(cell, max_value):
	
	var limit = max_value
		
	for i in range(2, max_value + 1):
			
		if(tileSet.get_cell_source_id(0, Vector2i(cell.x - i, cell.y - i)) != emptyID):
				
			limit = i - 1
			break
	
	return limit
	
func check_limit_up_right(cell, max_value):
	
	var limit = max_value
		
	for i in range(2, max_value + 1):
			
		if(tileSet.get_cell_source_id(0, Vector2i(cell.x + i, cell.y - i)) != emptyID):
				
			limit = i - 1
			break
	
	return limit
	
func check_limit_up(cell, max_value):
	
	var limit = max_value
		
	for i in range(2, max_value + 1):
			
		if(tileSet.get_cell_source_id(0, Vector2i(cell.x, cell.y - i)) != emptyID):
				
			limit = i - 1
			break
	
	return limit


func moveable_solid_behaviour(cell, down_left, down_right, type):
	
	if (tileSet.get_cell_source_id(0, down_left) == emptyID):
						
		move_cell(cell, -1, 1, type, rng.randi_range(0, 3))
						
	elif (tileSet.get_cell_source_id(0, down_right) == emptyID):
						
		move_cell(cell, 1, 1, type, rng.randi_range(0, 3))
						
	elif (tileSet.get_cell_source_id(0, down_left) == waterID):
						
		swap_cells(cell, -1, 1, type, waterID, rng.randi_range(0, 3), 0)
						
	elif (tileSet.get_cell_source_id(0, down_right) == waterID):
						
		swap_cells(cell, 1, 1, type, waterID, rng.randi_range(0, 3), 0)
		
	elif (tileSet.get_cell_source_id(0, down_left) == oilID):
						
		swap_cells(cell, -1, 1, type, oilID, rng.randi_range(0, 3), 0)
						
	elif (tileSet.get_cell_source_id(0, down_right) == oilID):
						
		swap_cells(cell, 1, 1, type, oilID, rng.randi_range(0, 3), 0)

func liquid_behaviour(cell, left, right, down_left, down_right, type, rate):
	
	if (tileSet.get_cell_source_id(0, down_left) == emptyID):
		
		var limit = check_limit_down_left(cell, rate)
		move_cell(cell, -limit, limit, type, 0)
						
	elif (tileSet.get_cell_source_id(0, down_right) == emptyID):
		
		var limit = check_limit_down_right(cell, rate)
		move_cell(cell, limit, limit, type, 0)
						
	elif (tileSet.get_cell_source_id(0, left) == emptyID):
		
		var limit = check_limit_left(cell, rate)
		move_cell(cell, -limit, 0, type, 0)
						
	elif (tileSet.get_cell_source_id(0, right) == emptyID):
		
		var limit = check_limit_right(cell, rate)
		move_cell(cell, limit, 0, type, 0)

func water_in_oil_behaviour(cell, left, right, down_left, down_right, type):
	
	if (tileSet.get_cell_source_id(0, down_left) == oilID):
		
		swap_cells(cell, -1, 1, type, oilID, 0, 0)
						
	elif (tileSet.get_cell_source_id(0, down_right) == oilID):
		
		swap_cells(cell, 1, 1, type, oilID, 0, 0)
						
	elif (tileSet.get_cell_source_id(0, left) == oilID):
		
		swap_cells(cell, -1, 0, type, oilID, 0, 0)
						
	elif (tileSet.get_cell_source_id(0, right) == oilID):
		
		swap_cells(cell, 1, 0, type, oilID, 0, 0)

func gas_behaviour(cell, left, right, up_left, up_right, type, rate):
	
	if (tileSet.get_cell_source_id(0, up_left) == emptyID):
						
		move_cell(cell, -rate, -rate, type, rng.randi_range(0, 3))
						
	elif (tileSet.get_cell_source_id(0, up_right) == emptyID):
						
		move_cell(cell, rate, -rate, type, rng.randi_range(0, 3))
						
	elif (tileSet.get_cell_source_id(0, left) == emptyID):
						
		move_cell(cell, -rate, 0, type, rng.randi_range(0, 3))
						
	elif (tileSet.get_cell_source_id(0, right) == emptyID):
						
		move_cell(cell, rate, 0, type, rng.randi_range(0, 3))
						
	else:
						
		transform_cell(cell, type, rng.randi_range(0, 3))

func _input(event):

	if Input.is_key_pressed(KEY_EQUAL):
		brushSize = brushSize + 1
		
		if brushSize > 15:
			brushSize = 15
			
	elif Input.is_key_pressed(KEY_MINUS):
		brushSize = brushSize - 1
		
		if brushSize < 0:
			brushSize = 0
	
	elif Input.is_key_pressed(KEY_H):
		if $Label.visible:
			$Label.hide()
		else:
			$Label.show()
		
	elif Input.is_key_pressed(KEY_0):
		currentBrush = waterID
		
	elif Input.is_key_pressed(KEY_1):
		currentBrush = oilID
		
	elif Input.is_key_pressed(KEY_2):
		currentBrush = lavaID
		
	elif Input.is_key_pressed(KEY_3):
		currentBrush = rockID
		
	elif Input.is_key_pressed(KEY_4):
		currentBrush = woodID
		
	elif Input.is_key_pressed(KEY_5):
		currentBrush = sandID
		
	elif Input.is_key_pressed(KEY_6):
		currentBrush = gunpowderID
		
	elif Input.is_key_pressed(KEY_7):
		currentBrush = fireID
		
	elif Input.is_key_pressed(KEY_8):
		currentBrush = smokeID
		
	elif Input.is_key_pressed(KEY_9):
		currentBrush = explosionID
		
	elif Input.is_key_pressed(KEY_R):
		var cells = tileSet.get_used_cells(0)
	
		for cell in cells:
			remove_cell(cell)
			
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and currentBrush != explosionID:
		
		for x in range (-brushSize, brushSize + 1):
			for y in range (-brushSize, brushSize + 1):
							
				if Vector2(x, y).length() <= brushSize:
					tileSet.set_cell(0, Vector2i(int(get_global_mouse_position().x + x) / 4, int(get_global_mouse_position().y + y) / 4), currentBrush, Vector2i(rng.randi_range(0, 3), 0))
					
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and currentBrush == explosionID:
		
		var radius = brushSize * 2.5
		
		for x in range (-radius, radius + 1):
			for y in range (-radius, radius + 1):
							
				if Vector2(x, y).length() <= radius:
					tileSet.set_cell(0, Vector2i(int(get_global_mouse_position().x + x) / 4, int(get_global_mouse_position().y + y) / 4), currentBrush, Vector2i(rng.randi_range(0, 3), 0))
					
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		
		for x in range (-brushSize, brushSize + 1):
			for y in range (-brushSize, brushSize + 1):
							
				if Vector2(x, y).length() <= brushSize:
					tileSet.set_cell(0, Vector2i(int(get_global_mouse_position().x + x) / 4, int(get_global_mouse_position().y + y) / 4), emptyID, Vector2i(0, 0))


func _on_timer_timeout():
	
	var cells = tileSet.get_used_cells(0)
		
	for cell in cells:
		
		if (cell.x >= size_x or cell.x < 0 or cell.y >= size_y or cell.y < 0):
			
			remove_cell(cell)

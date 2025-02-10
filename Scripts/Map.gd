extends Node

var mapGrid:Dictionary = {}
const HEIGHT:int = 20
const WIDTH:int = 10

const blockSize:int = 25

var polygon:Polygon2D = null

#key: a single integer representing row where 0 is top
#value: a boolean array of size 10. True = tile present, False = tile empty

#mapGrid[i][j] = i-th row from top, j-th column from left

func _ready():
	polygon = Polygon2D.new()
	var attachTo = get_tree().get_root().get_node("/root/Map")
	attachTo.add_child(polygon)
	polygon.color = Color.BLACK
	for i in HEIGHT:
		mapGrid[i] = Array()
		for j in WIDTH:
			mapGrid[i].append(false)
	#testMap()
			
func testMap():
	for i in 10:
		mapGrid[i][i] = true
		mapGrid[i+10][i] = true
		mapGrid[HEIGHT-1][i] = true
		mapGrid[4][i] = true
		mapGrid[13][i] = true
		mapGrid[0][i] = true
	drawMap()

#Ryan
func didTetrinoHitBottom(tetrino:Tetrino)->bool:
	return true
	pass

#jooyoung
func drawMap():
	var edit1 = polygon.polygon
	var edit2 = polygon.polygons
	edit1.clear()
	edit2.clear()
	polygon.polygon = edit1
	polygon.polygons = edit2
	for i in HEIGHT:
		for j in WIDTH:
			if mapGrid[i][j]:
				drawSquareAt(j, i)
	pass

func drawTetrino(tetrino:Tetrino):
	if tetrino == null:
		return
	for cur:Vector2i in tetrino.geometry:
		var position = tetrino.center + cur
		drawSquareAt(position.x, position.y)
	pass

func drawSquareAt(x:int, y:int):
	var startIdx = polygon.polygon.size()
	
	var editedPoly = polygon.polygon
	editedPoly.append(Vector2(x * blockSize, y * blockSize))
	editedPoly.append(Vector2((x+1) * blockSize, y * blockSize))
	editedPoly.append(Vector2((x+1) * blockSize, (y+1) * blockSize))
	editedPoly.append(Vector2(x * blockSize, (y+1) * blockSize))
	polygon.polygon = editedPoly
	
	#print("polygon size = " + str(polygon.polygon.size()))
	
	var arr = PackedInt32Array()
	for i in 4:
		arr.append(startIdx + i)
	polygon.polygons.append(
		arr
	)
	pass

#ryan
#print [ ] for empty locations, print [x] for filled-in locations, print [o] for tetrino tiles
func printCurrentMapWithTetrino(tetrino:Tetrino):
	pass

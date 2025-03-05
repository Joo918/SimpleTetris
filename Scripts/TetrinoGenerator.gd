extends Node


#define the different tetrino shapes in this class, and provide one at random on request
var tetrinoShapesList := {}
var tetrinoShapesArray := []
var RNG = RandomNumberGenerator.new()
var tetrinoindex := 0
var tetrinoQueue : Array[Tetrino] = []

func _ready():
	TetrinoGenerator.populateTetrinoShapesList()
	populateTetrinoQueue()

#TODO: don't hard code shapes list but gonna do it anyway right now for testing purposes
func populateTetrinoShapesList():
	tetrinoShapesArray = []
	# [ ][ ][ ]
	#    [C]
	tetrinoShapesList["T"] = [[Vector2i(0, 0), Vector2i(-1, -1),Vector2i(-1, 0),Vector2i(-1, 1)], Color.MEDIUM_PURPLE]
	
	# [ ][ ][C][ ]
	tetrinoShapesList["I"] = [[Vector2i(0, 0),Vector2i(0, -2),Vector2i(0, -1),Vector2i(0, 1)], Color.SKY_BLUE]
	
	# [ ][C]
	#    [ ][ ]
	tetrinoShapesList["S"] = [[Vector2i(0, 0),Vector2i(0,-1),Vector2i(1, 0),Vector2i(1, 1)], Color.LIME_GREEN]
	
	#    [C][ ]
	# [ ][ ]
	tetrinoShapesList["Z"] = [[Vector2i(0, 0),Vector2i(0, 1),Vector2i(1, -1),Vector2i(1, 0)], Color.RED]
	
	# [ ][C]
	# [ ][ ]
	tetrinoShapesList["O"] =[[Vector2i(0, 0),Vector2i(0, -1),Vector2i(1, -1),Vector2i(1, 0)], Color.YELLOW]
	
	# [ ][C][ ]
	# [ ]
	tetrinoShapesList["L"] = [[Vector2i(0, 0),Vector2i(0, -1),Vector2i(0, 1),Vector2i(1, -1)], Color.ORANGE]
	
	# [ ][C][ ]
	#       [ ]
	tetrinoShapesList["J"] = [[Vector2i(0, 0),Vector2i(0, -1),Vector2i(0, 1),Vector2i(1, 1)], Color.BLUE]
	for tetrino in tetrinoShapesList.keys():
		tetrinoShapesArray.append(tetrino)

func populateTetrinoQueue():
	for i in 3:
		tetrinoQueue.append(generateRandomTetrino())
	

func generateRandomTetrino()->Tetrino:
	print("generate new tetrino!")
	var tetrino := Tetrino.new()
	tetrinoindex = RNG.randi_range(0, (tetrinoShapesArray.size() - 1))
	#tetrino.geometry = tetrinoShapesList[0]["O"].duplicate()
	tetrino.geometry = tetrinoShapesList[tetrinoShapesArray[tetrinoindex]][0].duplicate()
	tetrino.color = tetrinoShapesList[tetrinoShapesArray[tetrinoindex]][1]
	tetrino.center = Vector2i(0,0)
	tetrino.polygon = Polygon2D.new()
	var attachTo = get_tree().get_root().get_node("/root/Map")
	attachTo.add_child(tetrino.polygon)
	return tetrino

#Ryan
#get tetrinos for preview
func getNext3Tetrinos()->Array[Tetrino]:
	return tetrinoQueue
	pass
	
#Ryan
#give next Tetrino in queue
#add one more generated Tetrino to queue
func takeNextTetrino()->Tetrino:
	tetrinoQueue.append(generateRandomTetrino())
	var nextTetrino = tetrinoQueue.pop_front()
	nextTetrino.center = Map.tetrinoSpawnLocation
	return nextTetrino
	
func CloneDropTetrino(tetrino)->Tetrino:
	var newTetrino := Tetrino.new()
	newTetrino.center = tetrino.center + Vector2i(0,5)
	newTetrino.geometry = tetrino.geometry.duplicate(true)
	newTetrino.color = Color(0,0,0,0.5)
	var polygon = Polygon2D.new()
	polygon.polygons = tetrino.polygon.polygons.duplicate(true)
	polygon.polygon = tetrino.polygon.polygon
	polygon.z_index = -1
	newTetrino.polygon = polygon
	var attachTo = get_tree().get_root().get_node("/root/Map")
	attachTo.add_child(newTetrino.polygon)
	return newTetrino

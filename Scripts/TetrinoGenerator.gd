extends Node


#define the different tetrino shapes in this class, and provide one at random on request
var tetrinoShapesList := {}
var tetrinoShapesArray := []
var RNG = RandomNumberGenerator.new()
var tetrinoindex := 0

func _ready():
	TetrinoGenerator.populateTetrinoShapesList()

#TODO: don't hard code shapes list but gonna do it anyway right now for testing purposes
func populateTetrinoShapesList():
	tetrinoShapesArray = []
	# [ ][ ][ ]
	#    [C]
	tetrinoShapesList["T"] = [Vector2i(0, 0), Vector2i(-1, -1),Vector2i(-1, 0),Vector2i(-1, 1)]
	
	# [ ][ ][C][ ]
	tetrinoShapesList["I"] = [Vector2i(0, 0),Vector2i(0, -2),Vector2i(0, -1),Vector2i(0, 1)]
	
	# [ ][C]
	#    [ ][ ]
	tetrinoShapesList["S"] = [Vector2i(0, 0),Vector2i(0,-1),Vector2i(1, 0),Vector2i(1, 1)]
	
	#    [C][ ]
	# [ ][ ]
	tetrinoShapesList["Z"] = [Vector2i(0, 0),Vector2i(0, 1),Vector2i(1, -1),Vector2i(1, 0)]
	
	# [ ][C]
	# [ ][ ]
	tetrinoShapesList["O"] = [Vector2i(0, 0),Vector2i(0, -1),Vector2i(1, -1),Vector2i(1, 0)]
	
	# [ ][C][ ]
	# [ ]
	tetrinoShapesList["L"] = [Vector2i(0, 0),Vector2i(0, -1),Vector2i(0, 1),Vector2i(1, -1)]
	
	# [ ][C][ ]
	#       [ ]
	tetrinoShapesList["J"] = [Vector2i(0, 0),Vector2i(0, -1),Vector2i(0, 1),Vector2i(1, 1)]
	for tetrino in tetrinoShapesList.keys():
		tetrinoShapesArray.append(tetrino)

func generateRandomTetrino()->Tetrino:
	var tetrino := Tetrino.new()
	tetrinoindex = RNG.randi_range(0, (tetrinoShapesArray.size() - 1))
	#tetrinoindex = 3
	tetrino.geometry = tetrinoShapesList[tetrinoShapesArray[tetrinoindex]]
	tetrino.center = Vector2i(5,2)
	return tetrino

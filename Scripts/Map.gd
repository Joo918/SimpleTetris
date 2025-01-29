extends Node

var mapGrid:Dictionary = {}
#key: a single integer representing row where 0 is top
#value: a boolean array of size 10. True = tile present, False = tile empty

#mapGrid[i][j] = i-th row from top, j-th column from left

func _ready():
	for i in 20:
		mapGrid[i] = Array()
		for j in 10:
			mapGrid[i][j] = false

#Ryan
func didTetrinoHitBottom(tetrino:Tetrino)->bool:
	return true
	pass

#jooyoung
func drawMap():
	pass

#ryan
#print [ ] for empty locations, print [x] for filled-in locations, print [o] for tetrino tiles
func printCurrentMapWithTetrino(tetrino:Tetrino):
	pass

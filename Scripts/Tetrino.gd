class_name Tetrino
extends Node

var center:Vector2i
var geometry #relative positions of the tiles forming the tetrino from the center.

#Ryan
#rotate current piece from the center in CCW direction
func rotateCCW():
	pass

#Ryan
#rotate current piece from the center in CCW direction	
#TODO: wall-kicking
func rotateCW():
	var count := 0
	var newGeometry := []
	for tile in geometry:
		newGeometry.append(Vector2(tile.x, tile.y).rotated(PI/2).round())
	for i in geometry.size():
		geometry[i] = Vector2i(newGeometry[i].x, newGeometry[i].y)
		
#Jooyoung
#check if rotation is not hitting any 
func isCurrentGeometryValid()->bool:
	return true
	pass

#Jooyoung
#shift the piece to make geometry valid
func resolveInvalidGeometry():
	pass
	

func printGeometry():
	print(center)
	print(geometry)

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
func isCurrentMoveValid(move: TetrinoMoveType)->bool:
	var clone := self.clone()
	match (move):
		TetrinoMoveType.R_CW:
			clone.rotateCW()
			pass
		TetrinoMoveType.R_CCW:
			clone.rotationCCW()
			pass
		TetrinoMoveType.RIGHT:
			clone.center += Vector2i.RIGHT
			pass
		TetrinoMoveType.LEFT:
			clone.center += Vector2i.LEFT
			pass
		TetrinoMoveType.DOWN:
			clone.center += Vector2i.UP
			pass
	var curMap := Map.mapGrid
	clone.printGeometry()
	for tile:Vector2i in clone.geometry:
		var cur:Vector2i = clone.center + tile
		if cur.x >= Map.WIDTH || cur.x < 0 || cur.y >= Map.HEIGHT || (cur.y >= 0 && curMap[cur.y][cur.x]):
			return false
	return true
	pass

	

func printGeometry():
	print(center)
	print(geometry)

func clone()->Tetrino:
	var newTetrino = Tetrino.new()
	
	newTetrino.center = self.center
	newTetrino.geometry = self.geometry.duplicate(true)
	
	return newTetrino

enum TetrinoMoveType {R_CW, R_CCW, LEFT, RIGHT, DOWN}

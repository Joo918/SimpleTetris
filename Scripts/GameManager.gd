class_name GameScene
extends Node

var currentActiveTetrino:Tetrino = null

var deltas:float = 0
const tickTime:float = 0.5 #tick is every 0.5 sec

var curHorizontalInput:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	currentActiveTetrino = TetrinoGenerator.generateRandomTetrino()
	pass

#Jooyoung
#TODO: make tetrino fall faster when pressing down
func _input(event):
	#if event.is_action_pressed('ui_left'):
		#curHorizontalInput -= 1
	#elif event.is_action_released('ui_left'):
		#curHorizontalInput += 1
	#if event.is_action_pressed('ui_right'):
		#curHorizontalInput += 1
	#elif event.is_action_released('ui_right'):
		#curHorizontalInput -= 1	
	if event.is_action_pressed('ui_left'):
		moveCurrentTetrinoOneStepHorizontal(-1)
	if event.is_action_pressed('ui_right'):
		moveCurrentTetrinoOneStepHorizontal(1)
	if event.is_action_pressed('ui_accept'):
		rotateCurrentActiveTetrino()

#jooyoung
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	deltas += delta
	if (deltas >= tickTime):
		deltas -= tickTime
		progressTick()
	#detect if input was made, and queue it to process in next tick
	pass

#jooyoung
# Updates position/rotation of current Tetrino per input, detect completed lines and erase them, update score
func progressTick():
	
	if (Map.didTetrinoHitBottom(currentActiveTetrino)):
		mergeCurrentTetrinoToMap()
		detectCompletedLinesAndErase()
		currentActiveTetrino = TetrinoGenerator.generateRandomTetrino()

	#move tetrino vertically
	moveCurrentTetrinoOneStepVertical()
	
	Map.drawMap()
	Map.drawTetrino(currentActiveTetrino)
	Map.printCurrentMapWithTetrino(currentActiveTetrino)
	pass


#Jooyoung
#delete completed lines and shift all others down (need to move from bottom to top)
func detectCompletedLinesAndErase():
	for i in range(Map.HEIGHT - 1, -1, -1):
		var deletedAtLeastOneLine = true
		while deletedAtLeastOneLine:
			var cur = Map.mapGrid[i]
			var cnt = 0
			for j in Map.WIDTH:
				if cur[j]:
					cnt += 1
			if cnt == Map.WIDTH:
				shiftDownFromAbove(i)
			else:
				deletedAtLeastOneLine = false
	pass
	
#recursively shift down map
func shiftDownFromAbove(idx:int):
	var cur = Map.mapGrid[idx]
	var above = Map.mapGrid[idx-1 if idx != 0 else 0]
	for i in Map.WIDTH:
		cur[i] = above[i] if idx != 0 else false
	if (idx != 0):
		shiftDownFromAbove(idx - 1)
	pass

#Ryan
func moveCurrentTetrinoOneStepVertical():
	currentActiveTetrino.center += Vector2i(0, 1)
	
func moveCurrentTetrinoOneStepHorizontal(value):
	currentActiveTetrino.center += Vector2i(value, 0)
	Map.drawMap()
	Map.drawTetrino(currentActiveTetrino)
	Map.printCurrentMapWithTetrino(currentActiveTetrino)
	
func rotateCurrentActiveTetrino():
	currentActiveTetrino.rotateCW()
	Map.drawMap()
	Map.drawTetrino(currentActiveTetrino)
	Map.printCurrentMapWithTetrino(currentActiveTetrino)
	
#jooyoung
# merge the current tetrino's geometry to the map
func mergeCurrentTetrinoToMap():
	if (currentActiveTetrino == null):
		return
	for cur:Vector2i in currentActiveTetrino.geometry:
		var position = currentActiveTetrino.center + cur
		Map.mapGrid[position.y][position.x] = true
	currentActiveTetrino.queue_free()
	currentActiveTetrino = null
	pass

#Jooyoung
#slam current tetrino to ground
func tetrinoButtThump():
	pass

#store current tetrino in a keep-space
#if there was on tetrino in the keep-space, use that as current piece,
#if not, get next piece from the generator
#Jooyoung
func keepPiece():
	pass


class_name GameScene
extends Node

@onready var backTexture := $BackgroundTexture
@onready var scorelabel := $ScoreLabel

@export var mapHeight := 20
@export var mapWidth := 10
@export var blockSize := 25

var scoreAmount := 0

var currentActiveTetrino:Tetrino = null
var heldTetrino:Tetrino = null
var dropPreviewTetrino:Tetrino = null

var deltas:float = 0
var tickTime:float = 0.5 #tick is every 0.5 sec

var curHorizontalInput:int = 0
var pressedDown:bool = false

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	Map.HEIGHT = mapHeight
	Map.WIDTH = mapWidth
	Map.blockSize = blockSize
	
func _ready():
	currentActiveTetrino = TetrinoGenerator.takeNextTetrino()
	dropPreviewTetrino = TetrinoGenerator.CloneDropTetrino(currentActiveTetrino)
	backTexture.size = Vector2(Map.blockSize * Map.WIDTH, Map.blockSize * Map.HEIGHT)
	scorelabel.position = Map.scoreLabelLocation * Map.blockSize
	drawCurrentScore()

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
	if event.is_action_pressed("ui_down"):
		tickTime = 0.25
	elif event.is_action_released('ui_down'):
		tickTime = 0.5
	if event.is_action_pressed('holdAction'):
		keepPiece()
	if event.is_action_pressed('slam'):
		tetrinoButtThump()
	if event.is_action_pressed('reset'):
		pass

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
		currentActiveTetrino = TetrinoGenerator.takeNextTetrino()
		dropPreviewTetrino.polygon.queue_free()
		dropPreviewTetrino = TetrinoGenerator.CloneDropTetrino(currentActiveTetrino)

	#move tetrino vertically
	moveCurrentTetrinoOneStepVertical()
	if (pressedDown):
		moveCurrentTetrinoOneStepVertical()
	
	
	render()
	#Map.printCurrentMapWithTetrino(currentActiveTetrino)
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
				scoreAmount += 1
			else:
				deletedAtLeastOneLine = false
	
#recursively shift down map
func shiftDownFromAbove(idx:int):
	var cur = Map.mapGrid[idx]
	var above = Map.mapGrid[idx-1 if idx != 0 else 0]
	for i in Map.WIDTH:
		cur[i] = above[i] if idx != 0 else false
	if (idx != 0):
		shiftDownFromAbove(idx - 1)

#Ryan
func moveCurrentTetrinoOneStepVertical():
	if currentActiveTetrino == null:
		return
	if currentActiveTetrino.isCurrentMoveValid(Tetrino.TetrinoMoveType.DOWN):
		currentActiveTetrino.center += Vector2i(0, 1)
	
func moveCurrentTetrinoOneStepHorizontal(value):
	if currentActiveTetrino == null:
		return
	var l = value < 0
	var horizontalValid = (l && currentActiveTetrino.isCurrentMoveValid(Tetrino.TetrinoMoveType.LEFT)) || (!l && currentActiveTetrino.isCurrentMoveValid(Tetrino.TetrinoMoveType.RIGHT))
	if (horizontalValid):
		currentActiveTetrino.center += Vector2i(value, 0)
		dropPreviewTetrino.center += Vector2i(value, 0)
		render()
		#Map.printCurrentMapWithTetrino(currentActiveTetrino)
	
func rotateCurrentActiveTetrino():
	if currentActiveTetrino == null:
		return
		
	if (currentActiveTetrino.isCurrentMoveValid(Tetrino.TetrinoMoveType.R_CW)):
		currentActiveTetrino.rotateCW()
		dropPreviewTetrino.rotateCW()
		print(currentActiveTetrino)
		render()
		#Map.printCurrentMapWithTetrino(currentActiveTetrino)
	
#jooyoung
# merge the current tetrino's geometry to the map
func mergeCurrentTetrinoToMap():
	if (currentActiveTetrino == null):
		return
	for cur:Vector2i in currentActiveTetrino.geometry:
		var position = currentActiveTetrino.center + cur
		Map.mapGrid[position.y][position.x] = true
	currentActiveTetrino.polygon.queue_free()
	currentActiveTetrino.queue_free()
	currentActiveTetrino = null
	pass

#Jooyoung
#slam current tetrino to ground
func tetrinoButtThump():
	if currentActiveTetrino == null:
		return
	while (!Map.didTetrinoHitBottom(currentActiveTetrino)):
		moveCurrentTetrinoOneStepVertical()
	render()
	pass

#store current tetrino in a keep-space
#if there was on tetrino in the keep-space, use that as current piece,
#if not, get next piece from the generator
#Jooyoung
func keepPiece():
	if (heldTetrino == null):
		heldTetrino = currentActiveTetrino
		currentActiveTetrino = TetrinoGenerator.takeNextTetrino()
		dropPreviewTetrino.polygon.queue_free()
		dropPreviewTetrino = TetrinoGenerator.CloneDropTetrino(currentActiveTetrino)		
		heldTetrino.center = Map.holdLocation
	else:
		var tmp = heldTetrino
		heldTetrino = currentActiveTetrino
		currentActiveTetrino = tmp
		currentActiveTetrino.center = heldTetrino.center
		heldTetrino.center = Map.holdLocation
		dropPreviewTetrino.polygon.queue_free()
		dropPreviewTetrino = TetrinoGenerator.CloneDropTetrino(currentActiveTetrino)
	render()
	pass

func render():
	Map.drawMap()
	Map.drawTetrino(currentActiveTetrino)
	Map.drawPreviewTetrinos()
	if heldTetrino != null:
		Map.drawTetrino(heldTetrino)
	drawCurrentScore()
	drawDropPreview()
		
#Ryan
#draws number of lines cleared
func drawCurrentScore():
	scorelabel.text = str("Score: " ,scoreAmount)
	
#draws a preview of where the tetrino is likely to land
func drawDropPreview():
	dropPreviewTetrino.center = currentActiveTetrino.center
	while (!Map.didTetrinoHitBottom(dropPreviewTetrino)):
		dropPreviewTetrino.center += Vector2i(0, 1)
	Map.drawTetrino(dropPreviewTetrino)

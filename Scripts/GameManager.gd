extends Node

var currentActiveTetrino:Tetrino = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#jooyoung
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#detect if input was made, and queue it to process in next tick
	pass

#jooyoung
# Updates position/rotation of current Tetrino per input, detect completed lines and erase them, update score
func progressTick():
	pass


#Jooyoung
#delete completed lines and shift all others down (need to move from bottom to top)
func detectCompletedLinesAndErase():
	pass
	

#Ryan
func moveCurrentTetrinoOneStep():
	pass

#jooyoung
# merge the current tetrino's geometry to the map
func mergeCurrentTetrinoToMap():
	pass

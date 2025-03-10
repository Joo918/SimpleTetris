GDPC                �                                                                         X   res://.godot/exported/133200997/export-e2c04f88cc384ae305072b7c73076002-GameScene.scn   P9      |      W�s��No9Qs-/�H;    ,   res://.godot/global_script_class_cache.cfg  0M            =�;�pUO�G����+    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�>            ：Qt�E�cO���       res://.godot/uid_cache.bin   R      >        T��[L��)�a��       res://GameScene.tscn.remap  �L      f       ���y��0	7-��"L        res://Scripts/GameManager.gd        .      dZu��qc;��6�       res://Scripts/Map.gd0             ;��m[=A*�`T�Y��       res://Scripts/Tetrino.gd0'      4      �<��_��+o��~�    $   res://Scripts/TetrinoGenerator.gd   p-      �      �]'6������&.	�       res://icon.svg  @N      �      k����X3Y���f       res://icon.svg.import   �K      �       ��˘���P��qF7 Q       res://project.binary@R      �      qQ�^���hx��+��        class_name GameScene
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
  extends Node

var mapGrid:Dictionary = {}
var HEIGHT:int = 20
var WIDTH:int = 10
var blockSize : int = 25

var holdLocation:Vector2i
var scoreLabelLocation:Vector2i
var previewLocation:Vector2i
var tetrinoSpawnLocation:Vector2i

var polygon:Polygon2D = null

#key: a single integer representing row where 0 is top
#value: a boolean array of size 10. True = tile present, False = tile empty

#mapGrid[i][j] = i-th row from top, j-th column from left

func _ready():
	holdLocation = Vector2i(2 + WIDTH,5)
	scoreLabelLocation = Vector2i(4 + WIDTH, 1)
	previewLocation = Vector2i(6 + WIDTH, 5)
	tetrinoSpawnLocation = Vector2i(floor(WIDTH/2) ,2)
	polygon = Polygon2D.new()
	var attachTo = get_tree().get_root().get_node("/root/Map")
	attachTo.add_child(polygon)
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
	
func testTetrinos():
	pass

#Ryan
#returns TRUE if the tetrino's geometry bottom is hitting the map's geometry
func didTetrinoHitBottom(tetrino:Tetrino)->bool:
	for tile in tetrino.geometry:
		var tilepos : Vector2 = tetrino.center + tile
		if tilepos.y >= HEIGHT - 1:
			return true
		if mapGrid[int(tilepos.y + 1)][int(tilepos.x)]:
			return true
	return false


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
				drawSquareAt(j, i, polygon)
	pass

#TODO: implement offset so we can use it for UI stuff (previews, keep-space)
func drawTetrino(tetrino:Tetrino, offset:Vector2i=Vector2i(0,0)):
	if tetrino == null:
		return
	var edit1 = tetrino.polygon.polygon
	var edit2 = tetrino.polygon.polygons
	edit1.clear()
	edit2.clear()
	tetrino.polygon.polygon = edit1
	tetrino.polygon.polygons = edit2
	for cur:Vector2i in tetrino.geometry:
		var position = tetrino.center + cur + offset
		drawSquareAt(position.x, position.y, tetrino.polygon, tetrino.color)
	pass

func drawSquareAt(x:int, y:int, poly : Polygon2D, color := Color.BLACK):
	var startIdx = poly.polygon.size()
	
	var editedPoly = poly.polygon
	editedPoly.append(Vector2(x * blockSize, y * blockSize))
	editedPoly.append(Vector2((x+1) * blockSize, y * blockSize))
	editedPoly.append(Vector2((x+1) * blockSize, (y+1) * blockSize))
	editedPoly.append(Vector2(x * blockSize, (y+1) * blockSize))
	poly.polygon = editedPoly
	
	#print("polygon size = " + str(polygon.polygon.size()))
	
	var arr = PackedInt32Array()
	for i in 4:
		arr.append(startIdx + i)
	poly.polygons.append(
		arr
	)
	poly.color = color

#ryan
#print [ ] for empty locations, print [x] for filled-in locations, print [o] for tetrino tiles
func printCurrentMapWithTetrino(tetrino:Tetrino):
	var tetrinotilecoord := []
	for tetrinotile in tetrino.geometry:
		tetrinotilecoord.append(tetrino.center + tetrinotile)
	for i in HEIGHT:
		var tilerowstring := ""
		for j in WIDTH:
			var tile = mapGrid[i][j]
			if tetrinotilecoord.has(Vector2i(j, i)):
				tilerowstring += "[o]"
			else:
				if tile:
					tilerowstring += "[x]"
				else:
					tilerowstring += "[ ]"
		print(tilerowstring)
	print("")
	
#Ryan
#draw the 3 tetrinos in preview next to map
func drawPreviewTetrinos():
	var offset := Vector2i(0, 5)
	var i = 0
	for tetrino in TetrinoGenerator.getNext3Tetrinos():
		drawTetrino(tetrino, previewLocation + (offset * i))
		i += 1
class_name Tetrino
extends Node

var center:Vector2i
var geometry #relative positions of the tiles forming the tetrino from the center.
var color := Color.BLACK
var polygon:Polygon2D = null

func _ready():
	pass

#Ryan
#rotate current piece from the center in CCW direction
func rotateCCW():
	pass

#Ryan
#rotate current piece from the center in CCW direction	
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
	#clone.printGeometry()
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
            extends Node


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
RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    diffuse_texture    normal_texture    specular_texture    specular_color    specular_shininess    texture_filter    texture_repeat    script 	   _bundled       Script    res://Scripts/GameManager.gd ��������      local://CanvasTexture_wv2gr �         local://PackedScene_83wm2 �         CanvasTexture    	         PackedScene    
      	         names "      
   GameScene    script    Node2D    BackgroundTexture 	   modulate    offset_right    offset_bottom    texture    TextureRect    ScoreLabel $   theme_override_font_sizes/font_size    text    Label    offset_left    offset_top    	   variants                                ��H>      B               �A   $         0     @qD     �A    ��D     �B   >   z = HOLD PIECE
x = SLAM DOWN
space = ROTATE
arrow keys = move       node_count             nodes     8   ��������       ����                            ����                                          	   ����               
                              ����                  	      
                   conn_count              conns               node_paths              editable_instances              version       	      RSRC    GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�m�m۬�}�p,��5xi�d�M���)3��$�V������3���$G�$2#�Z��v{Z�lێ=W�~� �����d�vF���h���ڋ��F����1��ڶ�i�엵���bVff3/���Vff���Ҿ%���qd���m�J�}����t�"<�,���`B �m���]ILb�����Cp�F�D�=���c*��XA6���$
2#�E.@$���A.T�p )��#L��;Ev9	Б )��D)�f(qA�r�3A�,#ѐA6��npy:<ƨ�Ӱ����dK���|��m�v�N�>��n�e�(�	>����ٍ!x��y�:��9��4�C���#�Ka���9�i]9m��h�{Bb�k@�t��:s����¼@>&�r� ��w�GA����ը>�l�;��:�
�wT���]�i]zݥ~@o��>l�|�2�Ż}�:�S�;5�-�¸ߥW�vi�OA�x��Wwk�f��{�+�h�i�
4�˰^91��z�8�(��yޔ7֛�;0����^en2�2i�s�)3�E�f��Lt�YZ���f-�[u2}��^q����P��r��v��
�Dd��ݷ@��&���F2�%�XZ!�5�.s�:�!�Њ�Ǝ��(��e!m��E$IQ�=VX'�E1oܪì�v��47�Fы�K챂D�Z�#[1-�7�Js��!�W.3׹p���R�R�Ctb������y��lT ��Z�4�729f�Ј)w��T0Ĕ�ix�\�b�9�<%�#Ɩs�Z�O�mjX �qZ0W����E�Y�ڨD!�$G�v����BJ�f|pq8��5�g�o��9�l�?���Q˝+U�	>�7�K��z�t����n�H�+��FbQ9���3g-UCv���-�n�*���E��A�҂
�Dʶ� ��WA�d�j��+�5�Ȓ���"���n�U��^�����$G��WX+\^�"�h.���M�3�e.
����MX�K,�Jfѕ*N�^�o2��:ՙ�#o�e.
��p�"<W22ENd�4B�V4x0=حZ�y����\^�J��dg��_4�oW�d�ĭ:Q��7c�ڡ��
A>��E�q�e-��2�=Ϲkh���*���jh�?4�QK��y@'�����zu;<-��|�����Y٠m|�+ۡII+^���L5j+�QK]����I �y��[�����(}�*>+���$��A3�EPg�K{��_;�v�K@���U��� gO��g��F� ���gW� �#J$��U~��-��u���������N�@���2@1��Vs���Ŷ`����Dd$R�":$ x��@�t���+D�}� \F�|��h��>�B�����B#�*6��  ��:���< ���=�P!���G@0��a��N�D�'hX�׀ "5#�l"j߸��n������w@ K�@A3�c s`\���J2�@#�_ 8�����I1�&��EN � 3T�����MEp9N�@�B���?ϓb�C��� � ��+�����N-s�M�  ��k���yA 7 �%@��&��c��� �4�{� � �����"(�ԗ�� �t�!"��TJN�2�O~� fB�R3?�������`��@�f!zD��%|��Z��ʈX��Ǐ�^�b��#5� }ى`�u�S6�F�"'U�JB/!5�>ԫ�������/��;	��O�!z����@�/�'�F�D"#��h�a �׆\-������ Xf  @ �q�`��鎊��M��T�� ���0���}�x^�����.�s�l�>�.�O��J�d/F�ě|+^�3�BS����>2S����L�2ޣm�=�Έ���[��6>���TъÞ.<m�3^iжC���D5�抺�����wO"F�Qv�ږ�Po͕ʾ��"��B��כS�p�
��E1e�������*c�������v���%'ž��&=�Y�ް>1�/E������}�_��#��|������ФT7׉����u������>����0����緗?47�j�b^�7�ě�5�7�����|t�H�Ե�1#�~��>�̮�|/y�,ol�|o.��QJ rmϘO���:��n�ϯ�1�Z��ը�u9�A������Yg��a�\���x���l���(����L��a��q��%`�O6~1�9���d�O{�Vd��	��r\�՜Yd$�,�P'�~�|Z!�v{�N�`���T����3?DwD��X3l �����*����7l�h����	;�ߚ�;h���i�0�6	>��-�/�&}% %��8���=+��N�1�Ye��宠p�kb_����$P�i�5�]��:��Wb�����������ě|��[3l����`��# -���KQ�W�O��eǛ�"�7�Ƭ�љ�WZ�:|���є9�Y5�m7�����o������F^ߋ������������������Р��Ze�>�������������?H^����&=����~�?ڭ�>���Np�3��~���J�5jk�5!ˀ�"�aM��Z%�-,�QU⃳����m����:�#��������<�o�����ۇ���ˇ/�u�S9��������ٲG}��?~<�]��?>��u��9��_7=}�����~����jN���2�%>�K�C�T���"������Ģ~$�Cc�J�I�s�? wڻU���ə��KJ7����+U%��$x�6
�$0�T����E45������G���U7�3��Z��󴘶�L�������^	dW{q����d�lQ-��u.�:{�������Q��_'�X*�e�:�7��.1�#���(� �k����E�Q��=�	�:e[����u��	�*�PF%*"+B��QKc˪�:Y��ـĘ��ʴ�b�1�������\w����n���l镲��l��i#����!WĶ��L}rեm|�{�\�<mۇ�B�HQ���m�����x�a�j9.�cRD�@��fi9O�.e�@�+�4�<�������v4�[���#bD�j��W����֢4�[>.�c�1-�R�����N�v��[�O�>��v�e�66$����P
�HQ��9���r�	5FO� �<���1f����kH���e�;����ˆB�1C���j@��qdK|
����4ŧ�f�Q��+�     [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dqpjcua1x8o2n"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                [remap]

path="res://.godot/exported/133200997/export-e2c04f88cc384ae305072b7c73076002-GameScene.scn"
          list=Array[Dictionary]([{
"base": &"Node",
"class": &"GameScene",
"icon": "",
"language": &"GDScript",
"path": "res://Scripts/GameManager.gd"
}, {
"base": &"Node",
"class": &"Tetrino",
"icon": "",
"language": &"GDScript",
"path": "res://Scripts/Tetrino.gd"
}])
           <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 814 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H446l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z" fill="#478cbf"/><path d="M483 600c0 34 58 34 58 0v-86c0-34-58-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
              g�]�FQ$v   res://GameScene.tscn�b&Q�`s   res://icon.svg  ECFG      application/config/name         SimpleTetris   application/run/main_scene         res://GameScene.tscn   application/config/features(   "         4.2    GL Compatibility       application/config/icon         res://icon.svg     autoload/Map          *res://Scripts/Map.gd      autoload/TetrinoGenerator,      "   *res://Scripts/TetrinoGenerator.gd     dotnet/project/assembly_name         SimpleTetris   input/holdAction�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   Z   	   key_label             unicode    z      echo          script      
   input/slam�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   X   	   key_label             unicode    x      echo          script         input/reset�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script      #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility      
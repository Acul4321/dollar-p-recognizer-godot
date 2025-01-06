extends Node2D

@export_category("Drawing Settings")
@export var line_width : float = 5
@export var joint_mode : int = 2
@export var cap_mode : int = 2

var can_draw : bool = true
var stroke : Line2D

var gesture_points : Array[PRecognizer.GesturePoint]

func _ready():
	PRecognizer.gestures.append(PRecognizer.Gesture.new("T",[PRecognizer.GesturePoint.new(30,7,1),PRecognizer.GesturePoint.new(103,7,1),PRecognizer.GesturePoint.new(66,7,2),PRecognizer.GesturePoint.new(66,87,2)]))
	PRecognizer.gestures.append(PRecognizer.Gesture.new("N",[PRecognizer.GesturePoint.new(177,92,1),PRecognizer.GesturePoint.new(177,2,1),PRecognizer.GesturePoint.new(182,1,2),PRecognizer.GesturePoint.new(246,95,2),PRecognizer.GesturePoint.new(247,87,3),PRecognizer.GesturePoint.new(247,1,3)]))
	PRecognizer.gestures.append(PRecognizer.Gesture.new("Line",[PRecognizer.GesturePoint.new(12,347,1),PRecognizer.GesturePoint.new(119,347,1)]))
	
	drawTemplate(PRecognizer.gestures[1])
	

func _input(event):
	if event.is_action_pressed("confirm"):
		gesture_points = confirmGesture()
		#point normalization needed for classification
		var tempGesture : PRecognizer.Gesture = PRecognizer.Gesture.new("",gesture_points)
		gesture_points = tempGesture.points
		
		var result : PRecognizer.Result = PRecognizer.Recognize(gesture_points)
		print(result.name)
		
		resetGesture()
	
	if can_draw:
		if event.is_action_pressed("draw"):
			stroke = Line2D.new()
			stroke.begin_cap_mode = cap_mode
			stroke.end_cap_mode = cap_mode
			stroke.antialiased = true
			stroke.width = line_width
			add_child(stroke)
		if event.is_action_released("draw"):
			stroke = null
			pass
			
# handles line drawing
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if can_draw and stroke != null:
			stroke.add_point(get_global_mouse_position())
			
func resetGesture():
	for child in get_children():
			child.queue_free()
	gesture_points.clear()

func confirmGesture() -> Array[PRecognizer.GesturePoint]:
	var gesture_points : Array[PRecognizer.GesturePoint]
	if(get_child_count() > 0):
		var strokes = get_children()
		for i in range(strokes.size()):
			var temp : Array[PRecognizer.GesturePoint] = lineToGesturePoints(strokes[i],i)
			gesture_points.append_array(temp)
	return gesture_points

func lineToGesturePoints(line : Line2D,id : int) -> Array[PRecognizer.GesturePoint]:
	var new_points : Array[PRecognizer.GesturePoint]
	for p in line.points:
		new_points.append(PRecognizer.GesturePoint.new(p.x,p.y,id))
	return new_points
	
func drawTemplate(gesture : PRecognizer.Gesture) -> void:
	var gesture_line : Line2D = $Line2D
	gesture_line.begin_cap_mode = cap_mode
	gesture_line.end_cap_mode = cap_mode
	gesture_line.antialiased = true
	gesture_line.width = line_width
	
	for i in range(gesture.points_raw.size()):
		var point : PRecognizer.GesturePoint = gesture.points_raw[i]
		gesture_line.add_point(Vector2(point.x,point.y))
		gesture_line.set_point_position(i,Vector2(point.x,point.y))

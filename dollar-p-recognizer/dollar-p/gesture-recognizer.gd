extends Node

class GesturePoint:
	var x: float
	var y: float
	var id: int #what stroke index the point belongs to
	var angle: float
	
	func _init(_x: float, _y: float, _id: int, _angle: float = 0.0):
		x = _x
		y = _y
		id = _id
		angle = _angle

class Gesture:
	var name: String
	var points: Array[GesturePoint]
	var points_raw: Array[GesturePoint]
	
	func _init(_name: String, _points: Array[GesturePoint]):
		name = _name
		
		points_raw =  TranslateTo(_points, GesturePoint.new(0, 0, 0))
		
		points = _points
		points = Resample(points, 32)
		points = Scale(points)
		points = TranslateTo(points, GesturePoint.new(0, 0, 0))
		points = ComputeNormalizedTurningAngles(points) #little error
		
	func Centroid(points : Array[GesturePoint]) -> GesturePoint:
		var x = 0.0
		var y = 0.0
		for point in points:
			x += point.x
			y += point.y
		x /= points.size()
		y /= points.size()
		return GesturePoint.new(x,y,0)
	
	func Distance(a : GesturePoint, b : GesturePoint) -> float: #euclidean distance between two points
		var dx = b.x - a.x
		var dy = b.y - a.y
		return sqrt(dx * dx + dy * dy)
	
	func PathLength(points : Array[GesturePoint]) -> float:
		var length : float = 0
		for i in range(1, points.size()):
			if points[i].id == points[i-1].id:
				length += Distance(points[i-1], points[i])
		return length
	
	func Resample(points : Array[GesturePoint], n : int) -> Array[GesturePoint]:
		var interval_length = PathLength(points) / (n - 1)
		var distance = 0.0
		var new_points : Array[GesturePoint]
		new_points.append(points[0])
		var i = 0
		while i < points.size():
			if(points[i].id == points[i-1].id):
				var d = Distance(points[i-1],points[i])
				if((distance + d) >= interval_length):
					var qx = points[i-1].x + ((interval_length - distance)/d) * (points[i].x - points[i-1].x)
					var qy = points[i-1].y + ((interval_length - distance)/d) * (points[i].y - points[i-1].y)
					var q = GesturePoint.new(qx,qy,points[i].id)
					new_points.append(q) #append new point q
					points.insert(i,q)
					distance = 0.0
				else:
					distance += d
			i += 1
		if new_points.size() == n - 1:
			new_points.append(points[points.size() - 1])
		return new_points
	
	func Scale(points : Array[GesturePoint]) ->Array[GesturePoint]:
		var min_x = INF
		var max_x = -INF
		var min_y = INF
		var max_y = -INF
		for point in points:
			min_x = min(min_x, point.x)
			min_y = min(min_y, point.y)
			max_x = max(max_x, point.x)
			max_y = max(max_y, point.y)
		var size = max(max_x - min_x, max_y - min_y)
		var new_points : Array[GesturePoint]
		for point in points:
			var qx = (point.x - min_x) / size
			var qy = (point.y - min_y) / size
			new_points.append(GesturePoint.new(qx,qy,point.id))
		return new_points
	
	func TranslateTo(points : Array[GesturePoint], pt :GesturePoint) -> Array[GesturePoint]:
		var c = Centroid(points)
		var new_points : Array[GesturePoint]
		for point in points:
			var qx = point.x + pt.x - c.x
			var qy = point.y + pt.y - c.y
			new_points.append(GesturePoint.new(qx,qy,point.id))
		return new_points
	
	func ComputeNormalizedTurningAngles(points : Array[GesturePoint]) -> Array[GesturePoint]:
		var new_points : Array[GesturePoint]
		new_points.append(points[0])
		for i in range(1,points.size()-2):
			var dx = (points[i+1].x - points[i].x) * (points[i].x - points[i-1].x)
			var dy = (points[i+1].y - points[i].y) * (points[i].y - points[i-1].y)
			var dn = Distance(points[i+1], points[i]) * Distance(points[i], points[i-1])
			var cos_angle = max(-1.0,min(1.0,(dx + dy) /dn))
			var angle = acos(cos_angle) / PI
			new_points.append(GesturePoint.new(points[i].x,points[i].y,points[i].id,angle))
		new_points.append(GesturePoint.new(points.back().x,points.back().y,points.back().id))
		return new_points

class Result:
	var name : String
	var score : float
	var time : float
	
	func _init(_name : String, _score : float, _time : float):
		name = _name
		score = _score
		time = _time

class PDollarPlusRecognizer:
	var gestures : Array[Gesture]
	
	# PDollarPlusRecognizer constants
	const NumPointClouds = 16; #dont need as we can just get the length
	const NumPoints = 32;
	var Origin = GesturePoint.new(0,0,0);
	
	func Recognize(points) -> Result:
		var t0 = Time.get_unix_time_from_system()
		var candidate = Gesture.new("",points)
		var u = -1
		var b = INF
		for i in range(gestures.size()):
			var d = min(CloudDistance(candidate.points,gestures[i].points),CloudDistance(gestures[i].points,candidate.points))
			if(d < b):
				b = d #best(min) distance
				u = i #gesture index
		var t1 = Time.get_unix_time_from_system()
		var curScore = 0.0
		if u == -1:
			return Result.new("No match.", curScore, t1 - t0)
		else:
			if (b > 1.0): curScore = 1.0 / b
			else: curScore = 1.0
			return Result.new(gestures[u].name, curScore, t1 - t0);
	
	func AddGesture(name : String,points : Array[GesturePoint]) -> bool:
		var newGesture : Gesture = Gesture.new(name,points)
		if(newGesture in gestures):
			return false
		gestures.append(newGesture)
		return true
		
	func getGestureIndexByName(name : String) -> int: #-1 for does not exist
		for i in range(gestures.size()):
			if gestures[i].name == name:
				return i
		return -1
	
	func DeleteGestureByName(name : String) -> bool:
		for i in range(gestures.size()-1):
			if name == gestures[i].name:
				gestures.remove_at(i)
				return true
		return false
		
	func DistanceWithAngle(p1 : GesturePoint, p2 : GesturePoint): #$P+
		var dx = p2.x - p1.x
		var dy = p2.y - p1.y
		var da = p2.angle - p1.angle
		return sqrt(dx * dx + dy * dy + da * da)
		
	func CloudDistance(pts1 : Array[GesturePoint],pts2 : Array[GesturePoint]):
		var matched : Array[bool]
		var length = min(pts1.size(),pts2.size())
		for k in range(length):
			matched.append(false)
		var sum = 0
		for i in range(length-1):
			var ind = -1
			var min = INF
			for j in range(length-1):
				var d = DistanceWithAngle(pts1[i],pts2[j])
				if d < min:
					min = d
					ind = j
			matched[ind] = true
			sum += min
		for j in range(matched.size()-1):
			if not(matched[j]):
				var min = INF
				for i in pts1.size()-1:
					var d = DistanceWithAngle(pts1[i],pts2[j])
					if d < min:
						min = d
				sum += min
		return sum

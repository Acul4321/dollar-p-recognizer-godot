# dollar-p-recognizer-godot

A godot implementation of the [Dollar P+ Point Cloud Recognizer](https://depts.washington.edu/acelab/proj/dollar/pdollarplus.html)

## About

>The $P+ Point-Cloud Recognizer is a 2-D gesture recognizer designed for rapid prototyping of gesture-based user interfaces, especially for people with low vision.
>
>$P+ improves the accuracy of the $P Point-Cloud Recognizer. $P+ was developed by carefully studying the stroke-gesture performance of people with low vision, which generated insights for how to improve $P for all users.

[Radu-Daniel Vatavu](http://www.eed.usv.ro/~vatavu/), University Stefan cel Mare of Suceava

## Usage
In the Godot Project Settings, upload the **gesture_recognizer.gd** as an Autoload script(Also known as a Singleton)[^1]
![image](https://github.com/user-attachments/assets/5bb3e271-aed4-4424-821c-1b4e34345960)

Now You must define In code The Recognizer and gestures you wish to classify.
#### Demo
``` gdscript
# if Autoload has been defined as 'PRecognizer' as above, we instantiate a Recognizer class
var Recognizer = PRecognizer.PDollarPlusRecognizer.new()

# Create the gesture, each containing a name and an array of 'GesturePoint' objects
# The 'GesturePoint' object has a x , y component aswell as an id(what stoke the point belongs to) and an angle
var gestureT = PRecognizer.Gesture.new("T",[
    PRecognizer.GesturePoint.new(30,7,1),
    PRecognizer.GesturePoint.new(103,7,1),
    PRecognizer.GesturePoint.new(66,7,2),
    PRecognizer.GesturePoint.new(66,87,2)])

var gestureLine = PRecognizer.Gesture.new("Line",[
    PRecognizer.GesturePoint.new(12,347,1),
    PRecognizer.GesturePoint.new(119,347,1)])

# Register what gestures a Recognizer can classify by appending to the 'gestures' array of Gesture objects
Recognizer.gestures.append(gestureT)
Recognizer.gestures.append(gestireLine)

# To classify the gestures we call the Recognize method to match with the previously registered Gesture objects
var result = Recognizer.Recognize(gesture_points)
print("Result: " + str(result.name) + " (" + str(round(result.score*100)) + ")  in " + str(round(result.time*1000)) + "ms")
```

[^1]: Singleton: A global script which contains functions and variables used throughtout the program.

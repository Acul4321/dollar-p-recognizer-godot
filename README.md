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
```

[^1]: Singleton: A global script which contains functions and variables used throughtout the program.

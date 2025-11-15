extends Resource
class_name QuizQuestion

@export_multiline var question : String
@export var options : Array[String] = []
@export var timer : int = 0
@export var correct_answer : String

class_name Task
extends Resource

enum Status { INCOMPLETE, COMPLETED }

@export var description: String
@export var deadline: int = 17 #the hour at which this task must be completed
var status : Status = Status.INCOMPLETE
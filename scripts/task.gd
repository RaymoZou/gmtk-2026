class_name Task
extends Resource

enum Status { INCOMPLETE, COMPLETED, FAILED }

@export var description: String
@export var deadline: int = 17
@export var status : Status = Status.INCOMPLETE

func complete_task() -> void:
	status = Status.COMPLETED
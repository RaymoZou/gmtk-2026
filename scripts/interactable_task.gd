extends Interactable

@export var task : Task

func _ready() -> void:
    print("%s is ready" % name)

func interact(_body: Node3D):
    if task and task.status != Task.Status.COMPLETED:
        print("task is now completed")
        task.complete_task()
        task_completed.emit(task)
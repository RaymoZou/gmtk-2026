@abstract
class_name Interactable
extends Area3D

@export var interact_text : String = "Interact"
@export var can_interact : bool = true

@abstract
func interact(_body: Node3D)

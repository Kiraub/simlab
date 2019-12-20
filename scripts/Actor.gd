tool
extends Entity

class_name Actor

enum ActorType {
	Idle,
	Waiter,
	Customer,
	Chef
}

export(ActorType) var actor_type
#export(int, FLAGS, "help", "what") var things

export(NodePath) var representation

func _init(displayName:String) -> void:
	setDisplayName(displayName)

func _ready() -> void:
	pass

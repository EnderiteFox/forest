class_name CustomCallback
extends Resource

@export var node: NodePath
@export var callback: StringName

func _init(node = ^"", callback = &""):
	self.node = node
	self.callback = callback

extends Spatial

export var priority = 0

func _ready():
	if TileHandler.canOverwriteWall(global_transform.origin,priority):
		TileHandler.wallList[global_transform.origin] = self
		set_process(false)

func _process(delta):
	call_deferred("queue_free")

func _exit_tree():
	if TileHandler.wallList.has(global_transform.origin):
		if TileHandler.wallList[global_transform.origin] == self:
			TileHandler.wallList.erase(global_transform.origin)

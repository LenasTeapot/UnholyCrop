extends NavigationRegion2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.rebake_navmesh.connect(func(): bake_navigation_polygon())

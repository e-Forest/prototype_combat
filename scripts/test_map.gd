@tool
extends NavigationRegion2D

func _process(delta):
	$Top.frame = $Objects.frame

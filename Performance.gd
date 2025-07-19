extends Label

var average_fps := 0
var total_fps := 0

func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	total_fps += fps
	var average_fps = total_fps/2.0
	total_fps = average_fps
	text = "FPS: " + str(fps) + "\n Average FPS: " + str(average_fps)

extends Label

var average_fps := 0
var total_checks := 0
var total_fps := 0

func _process(_delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	total_fps += fps
	total_checks += 1
	average_fps = total_fps/total_checks
	text = "FPS: " + str(fps) + "\n Average FPS: " + str(average_fps)

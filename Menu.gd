extends Control


var scene_to_load

func _ready():
	$Menu/PlayButton.connect("pressed", self, "on_button_pressed", [$Menu/PlayButton.scene_to_load])


func on_button_pressed(scene_path):
	scene_to_load = scene_path
	$ColorRect.show()
	$ColorRect/AnimationPlayer.play("fadein")


func _on_AnimationPlayer_animation_finished(_anim_name):
	get_tree().change_scene(scene_to_load)


func _on_ExitButton_pressed():
	get_tree().quit()

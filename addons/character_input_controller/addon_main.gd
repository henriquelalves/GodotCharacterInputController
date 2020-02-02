tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("CharacterInputController", "Control", preload("res://addons/character_input_controller/input_controller.gd"), preload("res://addons/character_input_controller/joystick_icon.png"))

func _exit_tree():
	remove_custom_type("CharacterInputController")

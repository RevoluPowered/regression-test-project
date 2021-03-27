extends Node

const screen_size = Vector2(1024, 600)

var start_time : int
var last_time : int

const PRINT_TIME_EVERY_MILISECONDS : int = 5000
var time_to_print_next_time : int = PRINT_TIME_EVERY_MILISECONDS

var time_to_show: int = 25 * 1000 # How long test works in miliseconds

var time_for_each_step : int = -1 

# Each scene runs alone
const alone_steps : Array = [
	"res://Physics/2D/Physics2D.tscn",
	"res://Physics/3D/Physics3D.tscn",
	"res://Rendering/Lights2D/Lights2D.tscn",
	"res://Rendering/Lights3D/Lights3D.tscn",
	"res://Nodes/Nodes.tscn",
	"res://ReparentingDeleting/ReparentingDeleting.tscn",
	"res://Text/Text.tscn",
]

# All scenes run in one step
# This should be put regression scripts which needs to run only once
const all_in_one : Array = [
"res://AIO/Operators/Operators.tscn",
"res://AutomaticBugs/FunctionExecutor.tscn",
#"res://AIO/AllNodes/ALL.tscn", # Take too much time - opens ~ 20 seconds in CI inside xvfb-run
]

func _ready(): 
	start_time = OS.get_ticks_msec()
	
	var time_set : bool = false
	
	for argument in OS.get_cmdline_args():
		if argument.is_valid_float(): # Ignore all non numeric arguments 
			time_set = true
			time_to_show = int(argument.to_float() * 1000)
			time_for_each_step = time_to_show / (alone_steps.size())
			print("Time set to: " + str(time_to_show / 1000.0) + " seconds with "+ str(alone_steps.size()) + " steps, each step will take " + str(time_for_each_step / 1000.0) + " seconds.")
			break # We only need to take first argument
			
	# In case when user doesn't provide time
	if !time_set:
		time_for_each_step = time_to_show / (alone_steps.size())
		print("Default time - " + str(time_to_show / 1000.0) + " seconds with "+ str(alone_steps.size()) + " steps, each step will take " + str(time_for_each_step / 1000.0) + " seconds.")


func _process(delta: float) -> void:
	var current_run_time : int = OS.get_ticks_msec() - start_time
	
	while current_run_time > time_to_print_next_time: # This will allow to properly regulate time under heavy operations(e.g. Thread sanitizer)
		print("Test is running now " + str(int(time_to_print_next_time / 1000)) + " seconds")
		time_to_print_next_time += PRINT_TIME_EVERY_MILISECONDS
		
	if current_run_time > time_to_show:
		print("######################## Ending test ########################")
		get_tree().quit()

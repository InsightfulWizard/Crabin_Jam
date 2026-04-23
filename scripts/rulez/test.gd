extends SceneTree

func _init():
	print("--- Logic Test Start ---")
	
	# Call your utility functions here
	var result = my_test_logic()
	print("Result: ", result)
	
	print("--- Logic Test End ---")
	
	# Important: Tell the process to stop
	quit()

func my_test_logic():
	return 1 + 1

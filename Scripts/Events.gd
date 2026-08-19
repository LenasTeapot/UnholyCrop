extends Node

@warning_ignore_start("unused_signal")

# Game State
signal exit_game
signal new_game
signal load_game
signal save_game

# UI
signal request_pop_up(scene_path, owning_node)
signal close_pop_up
signal pop_up_cancelled
signal pop_up_confirmed
signal toggle_quest_ui
signal accept_completed_quest
signal decline_completed_quest

# Management
signal pop_up_action(action)
signal request_worker(amount)
signal add_villager
signal add_plot(plot_data)

#signal change_crop(plot_node, new_crop_data)
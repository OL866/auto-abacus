extends SubViewport
func _ready():
	render_target_update_mode = UPDATE_ONCE 
	RenderingServer.frame_post_draw.connect(save)
func save():
	get_texture().get_image().save_png("user://Screenshot_BEADS_BG4.png")

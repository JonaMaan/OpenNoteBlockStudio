function draw_window_save_options() {
	// draw_window_save_options()
	var x1, y1, min_version;
	if (theme = 3) draw_set_alpha(windowalpha)
	curs = cr_default
	text_exists[0] = 0
	x1 = floor(rw / 2 - 72)
	y1 = floor(rh / 2 - 90)
	draw_window(x1, y1, x1 + 140, y1 + 162)
	draw_set_font(fnt_mainbold)
		if (theme = 3) draw_set_font(fnt_wslui_bold)
	draw_text(x1 + 8, y1 + 8, "Save options")
	draw_set_font(fnt_main)
		if (theme = 3) draw_set_font(fnt_wslui)
	if (theme = 0) {
	    draw_set_color(c_white)
	    draw_rectangle(x1 + 6, y1 + 26, x1 + 134, y1 + 132, 0)
	    draw_set_color(make_color_rgb(137, 140, 149))
	    draw_rectangle(x1 + 6, y1 + 26, x1 + 134, y1 + 132, 1)
	}
	draw_theme_color()
	
	min_version = 0
	if (user_instruments > 18) {
		min_version = 5
	}
	save_version = max(save_version, min_version)

	if (draw_radiobox(x1 + 15, y1 + 35, save_version = 5, "v5", "Increases custom instrument limit\nAllows custom sounds in subfolders", min_version > 5)) save_version = nbs_version
	if (draw_radiobox(x1 + 15, y1 + 50, save_version = 4, "v4", "Includes note velocity/pan/pitch and looping", min_version > 4)) save_version = 4
	if (draw_radiobox(x1 + 15, y1 + 65, save_version = 3, "v3", "Includes song length", min_version > 3)) save_version = 3
	if (draw_radiobox(x1 + 15, y1 + 80, save_version = 2, "v2", "Includes layer panning", min_version > 2)) save_version = 2
	if (draw_radiobox(x1 + 15, y1 + 95, save_version = 1, "v1", "Includes custom instrument index", min_version > 1)) save_version = 1
	if (draw_radiobox(x1 + 15, y1 + 110, save_version = 0, "Classic", "Doesn't have any of the above, but works on all versions.", min_version > 0)) save_version = 0

	if (draw_button2(x1 + 40, y1 + 135, 60, "OK") && windowopen = 1) {
		if save_version != nbs_version question("Some of the song's data will be lost if you save in a previous version! Are you sure?", "Confirm")
		changed = 1
		windowclose = 1
		}
	window_set_cursor(curs)
	window_set_cursor(cr_default)
	if (windowopen = 0 && theme = 3) {
		if (windowalpha < 1) {
			if (refreshrate = 0) windowalpha += 1/3.75
			else if (refreshrate = 1) windowalpha += 1/7.5
			else if (refreshrate = 2) windowalpha += 1/15
			else if (refreshrate = 3) windowalpha += 1/18
			else windowalpha += 1/20
		} else {
			windowalpha = 1
			windowopen = 1
		}
	}
	if(theme = 3) {
		if (windowclose = 1) {
			if (windowalpha > 0) {
				if (refreshrate = 0) windowalpha -= 1/3.75
				else if (refreshrate = 1) windowalpha -= 1/7.5
				else if (refreshrate = 2) windowalpha -= 1/15
				else if (refreshrate = 3) windowalpha -= 1/18
				else windowalpha -= 1/20
			} else {
				windowalpha = 0
				windowclose = 0
				windowopen = 0
				window = 0
				window_set_cursor(curs)
				save_settings()
			}
		}
	} else {
		if (windowclose = 1) {
			windowclose = 0
			window = 0
		}
	}
	draw_set_alpha(1)

}

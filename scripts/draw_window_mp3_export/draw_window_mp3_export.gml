function draw_window_mp3_export() {
	// draw_window_mp3_export()
	if (theme = 3) draw_set_alpha(windowalpha)
	var x1, y1
	curs = cr_default
	x1 = floor(rw / 2 - 125)
	y1 = floor(rh / 2 - 135)
	draw_window(x1, y1, x1 + 250, y1 + 270)
	draw_theme_font(font_main_bold)
	draw_text(x1 + 8, y1 + 8, "MP3 Export")
	draw_theme_font(font_main)

	if (theme != 3){
	draw_sprite(spr_mp3_exp, sch_exp_layout, x1 + 20, y1)
	} else {
	draw_sprite(spr_mp3_exp_f, fdark, x1 + 20, y1)
	}

	//Locked layers
	if (draw_checkbox(x1 + 16, y1 + 190, mp3_includelocked, "Include locked layers", "Whether to export locked layers in the MP3.", false, true)) mp3_includelocked= !mp3_includelocked
 
	//Submit button
	if (draw_button2(x1 + 165, y1 + 238, 72, "Export", false)) mp3_export()

	if (draw_button2(x1 + 10, y1 + 238, 72, "Cancel", false) && (windowopen = 1 || theme != 3)) {
		windowclose = 1
	}
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

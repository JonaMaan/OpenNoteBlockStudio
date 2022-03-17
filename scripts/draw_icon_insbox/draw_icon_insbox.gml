function draw_icon_insbox() {
	// draw_icon(i, xx, yy, str[, boxed[, isaction[, pressed]]])
	var i, a, xx, yy, str, boxed, isaction, pressed, clickable, sprite, push;
	i = argument[0]
	xx = argument[1]
	yy = argument[2]
	str = argument[3]
	// boxed = true only makes the button active when the instrument box is open
	boxed = (argument_count > 4 ? argument[4] : false)
	// isaction is set to true for the expand/collapse buttons
	isaction = (argument_count > 5 ? argument[5] : true)
	pressed = (argument_count > 6 ? argument[6] : false)
	clickable = (boxed ? window == w_insbox : window == 0)
	if (window = 0 || window = w_insbox) popup_set_window(xx, yy, 25, 25, str)
	a = (mouse_rectangle(xx, yy, 25, 25) && (clickable) && sb_drag = -1)
	a += ((mouse_check_button(mb_left) || mouse_check_button_released(mb_left)) && a)
	if (pressed = 1) {
	    draw_sprite(spr_frame1, 2 + 3 * theme + (fdark && theme = 3) * 3 - (a = 1) * (theme = 3), xx, yy)
		if (theme = 3) draw_sprite_ext(spr_tabsel, 1, xx + 5, yy + 23, 1, 1, 0, accent[4], 1)
	} else {
	    draw_sprite(spr_frame1, a + 3 * theme + (fdark && theme = 3) * 3, xx, yy)
	}
	sprite = isaction ? i : icons.INS_1 + min(i, first_custom_index)
	push = (a = 2 || pressed = 1) * (theme != 3)
	if (theme != 3) {
	draw_sprite(spr_icons, sprite, xx + push, yy + push)
	} else {
	if (!fdark) draw_sprite_ext(spr_icons_f, sprite, xx + push + 25 * 0.1 * (a = 2), yy + push + 23 * 0.1 * (a = 2), 1 - 0.2 * (a = 2), 1 - 0.2 * (a = 2), 0, -1, 1)
	else draw_sprite_ext(spr_icons_d, sprite, xx + push + 25 * 0.1 * (a = 2), yy + push + 23 * 0.1 * (a = 2), 1 - 0.2 * (a = 2), 1 - 0.2 * (a = 2), 0, -1, 1)
	}
	if (!isaction && i >= first_custom_index) {
		draw_icon_customins(xx + push, yy + push, i - first_custom_index, 1, false)
	}
	return (a && mouse_check_button_released(mb_left))



}

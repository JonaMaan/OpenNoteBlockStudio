function open_schematic(argument0) {
	// open_schematic(filename)
	// http://www.minecraftwiki.net/wiki/Alpha_Level_Format/Chunk_File_Format
	var fn, t;
	fn = argument0
	//if (confirm() < 0) return 0
	if (warning_schematic = 0) {
	    //message("NOTE: Schematic files generated by WorldEdit may load incorrectly or not at all.", "WorldEdit")
	    warning_schematic = 1
	}
	if (fn = "" || !file_exists_lib(fn)) fn = string(get_open_filename_ext("Minecraft Schematics (*.schematic)|*.schematic", "", "", "Import from Schematic"))
	if (fn = "" || !file_exists_lib(fn)) return 0
	reset_add()
	io_clear()
	array_push(songs, create(obj_song))
	set_song(array_length(songs) - 1)
	with (create(obj_dummy)) {
	    window = -1
	    d = sqrt(2000 * 256 * 2000)
	    var typestr;
	    // Initialize
	    t_AIR = 0
	    t_WIRE = 1
	    t_NOTE = 2
	    t_REPEATER = 3
	    t_TORCH = 4
	    t_BLOCK = 5
	    t_INPUT = 6
	    typestr[0] = "nothing"
	    typestr[1] = "wire"
	    typestr[2] = "note block"
	    typestr[3] = "repeater"
	    typestr[4] = "torch"
	    typestr[5] = "block"
	    typestr[6] = "input"
	    sch_width = 0
	    sch_length = 0
	    sch_height = 0
	    inputx[0] = -1
	    inputy[0] = -1
	    inputz[0] = -1
	    inputam = 0
	    noteblocks = 0
	    blockspos = -1
	    datapos = -1
	    offsetx = 0
	    offsety = 0
	    offsetz = 0
    
	    // Decompress
	    gzunzip(fn, temp_file)

	    // Read
	    buffer = buffer_load(temp_file)
	    nb_n = -1
	    nb_x = -1
	    nb_y = -1
	    nb_z = -1
	    buffer_read_byte() // 10
	    if (buffer_read_string_short_be() != "Schematic") { //"Schematic"
	        message("Failed to load Schematic.\n\nERROR: Not a Schematic file.", "Error")
	        window = 0
	        buffer_delete(buffer)
	        instance_destroy()
	        return 0
	    }
	    read_tags()
    
	    if (sch_width <= 0 || sch_length <= 0 || sch_height <= 0) {
	        message("Failed to load Schematic.\n\nERROR: Invalid size.", "Error")
	        window = 0
	        buffer_delete(buffer)
	        instance_destroy()
	        return 0
	    }
	    show_debug_message(sch_width)
	    show_debug_message(sch_length)
	    show_debug_message(sch_height)
	    if (blockspos < 0) {
	        message("Failed to load Schematic.\n\nERROR: No Blocks array found.", "Error")
	        window = 0
	        buffer_delete(buffer)
	        instance_destroy()
	        return 0
	    }
	    if (datapos < 0) {
	        message("Failed to load Schematic.\n\nERROR: No Data array found.", "Error")
	        window = 0
	        buffer_delete(buffer)
	        instance_destroy()
	        return 0
	    }
	    if (noteblocks = 0) {
	        message("Couldn't find any note blocks in the Schematic!", "Error") 
	        window = 0
	        buffer_delete(buffer)
	        instance_destroy()
	        return 0
	    }
    
	    // Parse blocks
    
	    var xx, yy, zz, n;
	    n = 0
	    buffer_seek(buffer, 0, blockspos)
	    for (zz = 0; zz < sch_height; zz += 1) {
	        for (xx = 0; xx < sch_length; xx += 1) {
	            for (yy = sch_width - 1; yy > -1; yy -= 1) {
	                var type;
	                a = buffer_read_byte()
	                t = xx * 2000 * 256 + zz * 2000 + yy
	                sch_block[t div d, t mod d] = a
	                sch_added[t div d, t mod d] = 0
	                type = t_AIR
	                if (a = 69 || a = 77) {
	                    inputx[inputam] = xx
	                    inputy[inputam] = yy
	                    inputz[inputam] = zz
	                    inputam += 1
	                } else if (a = 55) {
	                    type = t_WIRE
	                } else if (a = 25) {
	                    type = t_NOTE
	                } else if (a = 93 || a = 94) {
	                    type = t_REPEATER
	                } else if (a = 75 || a = 76) {
	                    type = t_TORCH
	                } else if (id_isblock(a)) {
	                    type = t_BLOCK
	                }
	                sch_type[t div d, t mod d] = type
	            }
	        }
	    }
	    buffer_seek(buffer, 0, datapos)
	    for (zz = 0; zz < sch_height; zz += 1) {
	        for (xx = 0; xx < sch_length; xx += 1) {
	            for (yy = sch_width - 1; yy > -1; yy -= 1) {
	                t = xx * 2000 * 256 + zz * 2000 + yy
	                sch_data[t div d, t mod d] = buffer_read_byte()
	            }
	        }
	    }
	    buffer_delete(buffer)
    
	    if (inputam = 0) {
	        message("The Schematic did not include any supported inputs.\nSupported inputs are:\n\n* Buttons\n* Levers", "Error")
	        window = 0
	        instance_destroy()
	        return 0
	    }
    
	    // Add note blocks
	    var a;
	    for (a = 0; a < noteblocks; a += 1) {
	        t = (noteblock_x[a] - offsetx) * 2000 * 256 + (noteblock_z[a] - offsety) * 2000 + (noteblock_y[a] - offsetz)
	        sch_block[t div d, t mod d] = 25
	        sch_data[t div d, t mod d] = noteblock_n[a]
	        sch_type[t div d, t mod d] = t_NOTE
	    }
	    // Place blocks
	    // http://www.minecraftwiki.net/wiki/Data_values#Data
	    var queuelength, queuet, queuex, queuey, queuez, queuedel, queueinput, queuenoteblocks, debugstr;
	    var i, a, b, c, cx, cy, cz, ct, cd, ci, tx, ty, tz, type, block, data, dir, str, stop, start;
	    debugstr = 1
	    queuenoteblocks = 0
	    for (i = 0; i < inputam; i += 1) {
	        queuelength = 1
	        queuet[0] = t_INPUT
	        queuex[0] = inputx[i]
	        queuey[0] = inputy[i]
	        queuez[0] = inputz[i]
	        start = obj_controller.enda + (16 * (i > 0))
	        queuedel[0] = 0
	        queueinput[0] = 0
	        t = inputx[i] * 2000 * 256 + inputz[i] * 2000 + inputy[i]
	        sch_added[t div d, t mod d] = 1
	        if (debugstr) {
	            if (i = 0) str = filename_name(fn) + ", width: " + string(sch_width) + ", length: " + string(sch_length) + ", height: " + string(sch_height) + ", inputs: " + string(inputam)
	            str += chr(13) + chr(10) + "_____INPUT " + string(i + 1) + "_____"
	        }
	        while (1) {
	            a = max(1, noteblocks)
	            queuelength -= 1
	            if (queuelength < 0) break
	            cx = queuex[queuelength]
	            cy = queuey[queuelength]
	            cz = queuez[queuelength]
	            ct = queuet[queuelength]
	            cd = queuedel[queuelength]
	            ci = queueinput[queuelength]
	            t = cx * 2000 * 256 + cz * 2000 + cy
	            if (ct = t_WIRE) { // Redstone wire
	                if (debugstr) str += chr(13) + chr(10) + "__Wire__"
	                for (b = 0; b < 4; b += 1) dir[b] = 0
	                for (a = -1; a < 2; a += 1) { // First round, wires and repeaters only
	                    for (b = 0; b < 4; b += 1) {
	                        tx = cx + (b = 1) - (b = 3)
	                        ty = cy + (b = 0) - (b = 2)
	                        tz = cz + a
	                        if (tx < 0 || ty < 0 || tz < 0 || tx >= sch_length || ty >= sch_width || tz >= sch_height) continue
	                        t = tx * 2000 * 256 + tz * 2000 + ty
	                        type = sch_type[t div d, t mod d]
	                        block = sch_block[t div d, t mod d]
	                        data = sch_data[t div d, t mod d]
	                        if (sch_added[t div d, t mod d] = 1) continue
	                        if (type = t_WIRE) {
	                            if (a = -1) { // Below
	                                t = tx * 2000 * 256 + cz * 2000 + ty
	                                if (sch_type[t div d, t mod d] = t_BLOCK) continue // The wire is blocked (see what I did there?)
	                            } else if (a = 1 && cz < sch_height - 1) { // Above
	                                t = cx * 2000 * 256 + (cz + 1) * 2000 + cy
	                                if (sch_type[t div d, t mod d] = t_BLOCK) continue // Wire is blocked
	                            }
	                            dir[b] = 1
	                        } else if (type = t_REPEATER) {
	                            if (3 - get_repeater_direction(data) != b) continue // Not facing same dir
	                            if (a = 1) continue
	                            if (a = 0) dir[b] = 1
	                        } else if (type = t_TORCH) {
	                            dir[b] = 1
	                        } else if (type = t_INPUT) {
	                            dir[b] = 1
	                        } else {
	                            continue
	                        }
	                        if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " next to wire"
	                        queuex[queuelength] = tx
	                        queuey[queuelength] = ty
	                        queuez[queuelength] = tz
	                        queuet[queuelength] = type
	                        queuedel[queuelength] = cd
	                        queueinput[queuelength] = ct
	                        queuelength += 1
	                        t = tx * 2000 * 256 + tz * 2000 + ty
	                        sch_added[t div d, t mod d] = 1
	                    }
	                }
	                for (b = 0; b < 4; b += 1) { // Second round, note blocks and blocks only
	                    tx = cx + (b = 1) - (b = 3)
	                    ty = cy + (b = 0) - (b = 2)
	                    tz = cz
	                    if (tx < 0 || ty < 0 || tz < 0 || tx >= sch_length || ty >= sch_width || tz >= sch_height) continue
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    block = sch_block[t div d, t mod d]
	                    data = sch_data[t div d, t mod d]
	                    if (sch_added[t div d, t mod d] = 1) continue
	                    a = (b + 1) mod 4
	                    if (dir[a] = 1) continue // Check dir
	                    a = b - 1
	                    if (a < 0) a = 3
	                    if (dir[a] = 1) continue // Check dir \n2
	                    if (type != t_NOTE && type != t_BLOCK) continue
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " next to wire"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                }
	                while (1) { // Block below?
	                    tx = cx
	                    ty = cy
	                    tz = cz - 1
	                    if (tz < 0) break
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    if (sch_added[t div d, t mod d] = 1) break
	                    if (type != t_BLOCK) break
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " below wire"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                    break
	                }
	            } else if (ct = t_REPEATER) {
	                if (debugstr) str += chr(13) + chr(10) + "__Repeater__"
	                while (1) { // Block in front of?
	                    b = (get_repeater_direction(sch_data[t div d, t mod d]) + 2) mod 4
	                    tx = cx + (b = 0) - (b = 2) // Item in front of
	                    ty = cy + (b = 1) - (b = 3)
	                    tz = cz
	                    if (tx < 0 || ty < 0 || tz < 0 || tx >= sch_length || ty >= sch_width || tz >= sch_height) break
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    block = sch_block[t div d, t mod d]
	                    data = sch_data[t div d, t mod d]
	                    if (sch_added[t div d, t mod d] = 1) break
	                    if (type = t_AIR || type = t_TORCH) break
	                    if (type = t_REPEATER) {
	                        if (((get_repeater_direction(data) + 2) mod 4) != b) break // It must be facing the same dir
	                    }
	                    t = cx * 2000 * 256 + cz * 2000 + cy
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " next to repeater"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd + get_repeater_delay(sch_data[t div d, t mod d]) + 1
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                    break
	                }
	            } else if (ct = t_BLOCK) {
	                if (debugstr) str += chr(13) + chr(10) + "__Block__"
	                while (1) { // Look below
	                    tx = cx
	                    ty = cy
	                    tz = cz - 1
	                    if (tz < 0) break
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    if (sch_added[t div d, t mod d] = 1) break
	                    if (type != t_WIRE) break
	                    if (ci = t_WIRE) break
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " below block"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                    break
	                }
	                while (1) { // Look above
	                    tx = cx
	                    ty = cy
	                    tz = cz + 1
	                    if (tz >= sch_height) break
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    if (sch_added[t div d, t mod d] = 1) break
	                    if (type != t_TORCH && type != t_WIRE) break
	                    if (ci = t_WIRE) {
	                        if (type = t_WIRE) break
	                    }
	                    if (sch_data[t div d, t mod d] != 5 && type = t_TORCH) break
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " above block"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                    break
	                }
	                for (b = 0; b < 4; b += 1) { // Look around
	                    tx = cx + (b = 1) - (b = 3)
	                    ty = cy + (b = 0) - (b = 2)
	                    tz = cz
	                    if (tx < 0 || ty < 0 || tz < 0 || tx >= sch_length || ty >= sch_width || tz >= sch_height) continue
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    block = sch_block[t div d, t mod d]
	                    data = sch_data[t div d, t mod d]
	                    if (sch_added[t div d, t mod d] = 1) continue
	                    if (type = t_TORCH) {
	                        if (data = 1) {
	                            if (b != 2) continue
	                        } else if (data = 2) {
	                            if (b != 0) continue
	                        } else if (data = 3) {
	                            if (b != 1) continue
	                        } else if (data = 4) {
	                            if (b != 3) continue
	                        } else {
	                            continue
	                        }
	                    } else if (type = t_REPEATER) {
	                        if (get_repeater_direction(data) != 3 - b) continue
	                    } else if (type = t_WIRE) {
	                        if (ci = t_WIRE) continue
	                    } else if (type != t_NOTE) {
	                        continue
	                    }
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " next to block"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                }
	            } else if (ct = t_NOTE) {
	                if (debugstr) str += chr(13) + chr(10) + "__Note block__"
	                a = 0
	                if (cz > -1) {
	                    t = cx * 2000 * 256 + (cz - 1) * 2000 + cy
	                    a = block_get_ins(sch_block[t div d, t mod d])
	                }
	                while (1) {
	                    stop = 0
	                    /*for (b = 0 b < 4 b += 1) { // Check for powered redstone around
	                        tx = cx + (b = 1) - (b = 3)
	                        ty = cy + (b = 0) - (b = 2)
	                        tz = cz
	                        if (tx < 0 || ty < 0 || tz < 0 || tx >= sch_length || ty >= sch_width || tz >= sch_height) continue
	                        t = tx * 2000 * 256 + tz * 2000 + ty
	                        type = sch_type[t div d, t mod d]
	                        block = sch_block[t div d, t mod d]
	                        data = sch_data[t div d, t mod d]
	                        if (type = t_WIRE && data > 0) { // Powered redstone next to it
	                            stop = 1
	                            break
	                        }
	                        if (block = 94) {
	                            if (get_repeater_direction(data) != (b + 3) mod 4) { // Powered repeater next to it
	                                stop = 1
	                                break
	                            }
	                        }
	                    }*/
	                    if (cz + 1 < sch_height) { // No air above block?
	                        t = cx * 2000 * 256 + (cz + 1) * 2000 + cy
	                        if (sch_type[t div d, t mod d] = t_BLOCK) stop = 1
	                    }
	                    if (stop > 0) {
	                        if (debugstr) str += chr(13) + chr(10) + "Didn't add note block."
	                        break
	                    }
	                    t = cx * 2000 * 256 + cz * 2000 + cy
	                    b = 0
	                    c = sch_data[t div d, t mod d] + 33
	                    queuenoteblocks += 1
	                    if (debugstr) str += chr(13) + chr(10) + "Added note block no. " + string(queuenoteblocks) + "!"
	                    with (obj_controller) {
	                        d = sqrt(2000 * 256 * 2000)
	                        while (!add_block(start + cd, b, obj_controller.songs[obj_controller.song].instrument_list[| a], c, 100, 100, 0)) b += 1
	                    }
	                    break
	                }
	            } else if (ct = t_TORCH) {
	                if (debugstr) str += chr(13) + chr(10) + "__Torch__"
	                while (1) { // Wire below?
	                    tx = cx
	                    ty = cy
	                    tz = cz - 1
	                    if (tz < 0) break
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    if (sch_added[t div d, t mod d] = 1) break
	                    if (type != t_WIRE) break
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " below torch"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd + 1
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                    break
	                }
	                while (1) { // Block above?
	                    tx = cx
	                    ty = cy
	                    tz = cz + 1
	                    if (tz >= sch_height) break
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    if (sch_added[t div d, t mod d] = 1) break
	                    if (type != t_BLOCK && type != t_NOTE) break
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " above torch"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd + 1
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                    break
	                }
	                for (b = 0; b < 4; b += 1) { // Wires or repeaters next to
	                    tx = cx + (b = 1) - (b = 3)
	                    ty = cy + (b = 0) - (b = 2)
	                    tz = cz
	                    if (tx < 0 || ty < 0 || tz < 0 || tx >= sch_length || ty >= sch_width || tz >= sch_height) continue
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    block = sch_block[t div d, t mod d]
	                    data = sch_data[t div d, t mod d]
	                    if (sch_added[t div d, t mod d] = 1) continue
	                    if (type = t_REPEATER) {
	                        if (get_repeater_direction(data) != 3 - b) continue
	                    } else if (type != t_WIRE) {
	                        continue
	                    }
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " next to torch"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd + 1
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                }
	            } else if (ct = t_INPUT) {
	                if (debugstr) str += chr(13) + chr(10) + "__Input__"
	                while (1) { // Block below?
	                    tx = cx
	                    ty = cy
	                    tz = cz - 1
	                    if (tz < 0) break
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    if (sch_added[t div d, t mod d] = 1) break
	                    t = cx * 2000 * 256 + cz * 2000 + cy
	                    if (type != t_BLOCK && type != t_WIRE) break
	                    if (type = t_BLOCK && sch_block[t div d, t mod d] != 69) break
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " below input"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                    break
	                }
	                for (b = 0; b < 4; b += 1) {
	                    tx = cx + (b = 1) - (b = 3)
	                    ty = cy + (b = 0) - (b = 2)
	                    tz = cz
	                    if (tx < 0 || ty < 0 || tz < 0 || tx >= sch_length || ty >= sch_width || tz >= sch_height) continue
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    type = sch_type[t div d, t mod d]
	                    block = sch_block[t div d, t mod d]
	                    data = sch_data[t div d, t mod d]
	                    if (type = 0) continue
	                    if (sch_added[t div d, t mod d] = 1) continue
	                    if (type = t_NOTE || type = t_TORCH) continue
	                    if (debugstr) str += chr(13) + chr(10) + "Found " + typestr[type] + " next to input"
	                    queuex[queuelength] = tx
	                    queuey[queuelength] = ty
	                    queuez[queuelength] = tz
	                    queuet[queuelength] = type
	                    queuedel[queuelength] = cd
	                    queueinput[queuelength] = ct
	                    queuelength += 1
	                    t = tx * 2000 * 256 + tz * 2000 + ty
	                    sch_added[t div d, t mod d] = 1
	                }
	            }
	        }
	    }
	    window = 0
	    if (debugstr) clipboard_set_text(str)
	    if (queuenoteblocks = 0) {
	        message("None of the note blocks in the Schematic could be added. This could be to none of them being connected to any inputs (buttons or levers).", "Error")
	        instance_destroy()
	        return 0
	    }
	    if (inputam > 1) message("The Schematic contained more than one input.\n\nAs a result, the songs of the inputs have been put after each other.", "Schematic import")
	    obj_controller.songs[obj_controller.song].filename = fn
	    obj_controller.songs[obj_controller.song].midifile = filename_name(fn)
	    instance_destroy()
	}



}

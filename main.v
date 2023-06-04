module main

// import glfw
// import stbi
import gg
import gx
import time
import rand
import math

const (
	win_width                = 801 // 1602 / 2
	win_height               = 556 // 1112 / 2
	bg_color                 = gx.white
	hex_w                    = 44
	hex_height               = 32
	hex_width                = 44 // 37
	hex_color                = gx.rgb(93, 126, 4)
	battle_width             = 15 // 15 hexes
	battle_height            = 11 // 11 hexes
	unit_number_bg_color     = gx.rgb(99, 33, 165) // 148,0,211)  // purple
	unit_number_border_color = gx.yellow
	grid_y_padding           = 100 // px // space between the top window edge and the start of the grid
	grid_x_padding           = 77 // px
)

struct Point {
	x int
	y int
}

struct Game {
mut:
	gg             &gg.Context
	battle_img     gg.Image
	img            gg.Image
	// images     [][]gg.Image
	// img2       []gg.Image
	anim_i         int
	frame          int
	units          []Unit
	selected_hex   Point
	hex_to_move_to Point
	cur_unit_idx   int // index of the unit whose turn it is
	moving_unit_x  f32 // pixels
	moving_unit_y  f32 // pixels
	x_speed        f32 // px/frame
	y_speed        f32 // px/frame
	// dx f32
}

fn main() {
	println(unit_names)
	mut game := &Game{}
	// images: [][]gg.Image{len: 100}
	game.gg = gg.new_context({
		width: win_width
		height: win_height
		use_ortho: true
		create_window: true
		window_title: 'V Heroes'
		frame_fn: frame
		move_fn: mouse_move
		click_fn: mouse_click
		user_data: game
		bg_color: bg_color
		font_path: 'RobotoMono-Regular.ttf'
	})
	game.units = [
		game.new_unit(.angel),
		game.new_unit(.angel),
		game.new_unit(.monk),
		game.new_unit(.sword),
		game.new_unit(.crusader),
		game.new_unit(.zealot),
		// /
		game.new_unit(.angel),
		game.new_unit(.angel),
		game.new_unit(.monk),
		game.new_unit(.sword),
		game.new_unit(.crusader),
		game.new_unit(.zealot),
	]
	//game.units[0].x= 3
	game.units[0].count = 1
	game.units[1].count = 1
	game.units[2].count = 3
	game.units[3].count = 6
	game.units[4].count = 5
	game.units[5].count = 2
	game.units[0].y = 0
	game.units[1].y = 2
	game.units[2].y = 4
	game.units[3].y = 6
	game.units[4].y = 8
	game.units[5].y = 10
	//
	game.units[6].count = 1
	game.units[7].count = 2
	game.units[8].count = 3
	game.units[9].count = 4
	game.units[10].count = 5
	game.units[11].count = 6
	game.units[6].y = 0
	game.units[7].y = 2
	game.units[8].y = 4
	game.units[9].y = 6
	game.units[10].y = 8
	game.units[11].y = 10
	game.units[6].side = .right
	game.units[7].side = .right
	game.units[8].side = .right
	game.units[9].side = .right
	game.units[10].side = .right
	game.units[11].side = .right
	game.units[6].x = 14
	game.units[7].x = 14
	game.units[8].x = 15
	game.units[9].x = 15
	game.units[10].x = 15
	game.units[11].x = 15
	// ctx.gg.window.set_user_ptr(ctx) // TODO remove this when `window_user_ptr:` works
	// gg.clear(bg_color)
	// stbi.set_flip_vertically_on_load(true)
	// game.battle_img = game.gg.create_image('bitmap/cmbkgrtr.png')
	game.battle_img = game.gg.create_image('bitmap/cmbkgrmt.png')
	game.img = game.gg.create_image('pic/dusa.png')
	game.img = game.gg.create_image('anim/crangl.dir/00_00.png')
	// mut images := []u32{}
	/*
	for unit in game.units {
		game.images[int(unit.kind)] = []gg.Image{len: unit.info.nr_anims}
		// game.images << game.gg.create_image('anim/crangl${i}.png')
		// game.images << game.gg.create_image('anim/crangl.dir/00_0${i}.png')
		// game.images << game.gg.create_image('anim/cmonkk.dir/00_0${i}.png')
		for i in 0 .. unit.info.nr_anims {
			path := 'anim/c${unit.name()}.dir/00_0${i}.png'
			// path := 'anim/crangl.dir/00_0${i}.png'
			println(path)
			game.images[int(unit.kind)][i] = game.gg.create_image(path)
			// //game.img2 <<  game.gg.create_image(path)
		}
	}
	*/
	// println(game.images[UnitKind.angel].len)
	go game.loop()
	game.gg.run()
}

fn (ctx &Game) draw_hex(xpos, ypos int, selected bool) {
	w := hex_width // int(f32(hex_width) * 1.2)
	pad := if ypos % 2 == 0 { 77 } else { 55 }
	// g.draw_hex(pad+ w *x,100+y*(hex_height+10))
	x := pad + w * xpos
	y := grid_y_padding + ypos * (hex_height + 10)
	color := if selected { gx.Color{0, 0, 0, 200} } else { gx.Color{0, 0, 0, 100} }
	ctx.gg.draw_triangle(x, y, x + w / 2, y - 10, x + w, y, color) // top triangle
	ctx.gg.draw_rect(x, y, w - 1, hex_height - 1, color) // center
	ctx.gg.draw_triangle(x, y + hex_height - 1, x + w / 2, y + hex_height + 9, x + w,
		y + hex_height - 1, color) // bottom triangle
	/*
	if true {return}

	ctx.gg.draw_rect(x, y, 2, hex_height, hex_color) // left
	// ctx.gg.draw_line(x,y, x,y + hex_width, hex_color) // left
	// ctx.gg.draw_line(x+1,y, x+1,y + hex_width, hex_color) // left
	// ////////
	ctx.gg.draw_rect(x + w, y, 2, hex_height, hex_color) // right
	// ctx.gg.draw_line(x+hex_width,y, x+hex_width,y + hex_width, hex_color) // right
	// ///////
	ctx.gg.draw_line(x, y, x + w / 2, y - 10, hex_color) // top left
	ctx.gg.draw_line(x + 1, y, x + w / 2 + 1, y - 10, hex_color) // top left
	ctx.gg.draw_line(x + 2, y, x + w / 2 + 2, y - 10, hex_color) // top left
	// //////
	ctx.gg.draw_line(x + w / 2, y - 10, x + w, y, hex_color) // top right
	ctx.gg.draw_line(x + w / 2 + 1, y - 10, x + w + 1, y, hex_color) // top right
	ctx.gg.draw_line(x + w / 2 + 2, y - 10, x + w + 2, y, hex_color) // top right
	*/
}

fn frame(mut game Game) {
	game.frame++
	if game.frame > 60 {
		game.frame = 0
	}
	if game.frame % 10 == 0 {
		game.anim_i++
		// if game.anim_i >= 5 {
		// game.anim_i = 0
		// }
	}
	game.gg.begin()
	game.draw_scene()
	game.gg.end()
}

fn (mut g Game) loop() {
	for {
		// Randomly set one unit's state to "hover" every 2 seconds
		idx := rand.intn(g.units.len)
		if g.units[idx].anim_state == .wait {
			g.units[idx].anim_state = .hover
		}
		/*
		for i, unit in g.units {
			if unit.anim_state == .wait {
				g.units[i].anim_state = .hover
			}
		}
		*/
		time.sleep_ms(1000)
		for i, unit in g.units {
			if unit.anim_state == .hover {
				g.units[i].anim_state = .wait
			}
		}
		time.sleep_ms(1000 * (rand.intn(3) + 1))
	}
}

const (
	move_px_per_frame = 3
)

fn hex_to_pixel(x, y int) (f32, f32) {
	return grid_x_padding + x * hex_width, grid_y_padding + y * hex_width
}

fn mouse_click(mx, my f32, mut g Game) {
	println('click: $mx, $my')
	g.hex_to_move_to = g.selected_hex
	println(g.hex_to_move_to)
	unit := g.units[g.cur_unit_idx]
	// Calculate x_speed and y_speed (by what amount of pixels the unit should be moved in each frame)
	// start_x := grid_x_padding +  unit.x * hex_width  // get start pos in pixels
	// start_y := grid_y_padding +  unit.y * hex_width
	start_x, start_y := hex_to_pixel(unit.x, unit.y)
	// get end pos in pixels
	end_x, end_y := hex_to_pixel(g.hex_to_move_to.x, g.hex_to_move_to.y)
	println('$end_x, $end_y')
	distance_to_travel := (math.sqrt(end_x * end_x + start_x * start_x)) // vector between start end end points
	time_to_travel := distance_to_travel / f32(move_px_per_frame)
	// now that we know how long it'll be moving in total, calculate the vertical and horizontal speed
	// speed = dist / time
	g.x_speed = f32(math.abs(end_x - start_x) / time_to_travel)
	g.y_speed = f32(math.abs(end_y - start_y) / time_to_travel)
	//
	g.moving_unit_x, g.moving_unit_y = start_x, start_y
	// println('dx=$dx')
	g.units[g.cur_unit_idx].anim_state = .move
}

fn mouse_move(mx, my f32, mut g Game) {
	//println('move $mx, $my')
	x := int((mx - grid_x_padding) / hex_height) - 1
	y := int((my - grid_y_padding) / hex_width) // battle_width
	// x := int(mx / hex_height)
	// y := int(my / hex_width) // battle_width
	g.selected_hex = Point{x, y}
	// g.moving_unit_x =
}

fn (mut g Game) draw_scene() {
	// println('frame ${g.anim_i%3}')
	// mut anim_i := 0
	// g.gg.clear(bg_color)
	g.gg.draw_image(0, 0, win_width, win_height, g.battle_img) // background
	// g.gg.draw_image(10, 10, 400, 400, g.img)
	// if g.images.len == 0 {
	// return
	// }
	for x in 0 .. battle_width {
		for y in 0 .. battle_height {
			// pad := if y % 2 == 0 { 80 } else { 102 }
			// g.draw_hex(pad+ w *x,100+y*(hex_height+10))

			selected := x == g.selected_hex.x && y == g.selected_hex.y
			g.draw_hex(x, y, selected)
			// 2hex unit shadow
			if selected && g.units[g.cur_unit_idx].info.large {
				g.draw_hex(x+1, y, true)

			}

		}
	}
	// Units
	mut i_left, mut i_right := 0, 0
	for i, unit in g.units {
		if unit.anim_state == .move {
			g.moving_unit_x += g.x_speed
			g.moving_unit_y += g.y_speed
			dest_x, dest_y := hex_to_pixel(g.hex_to_move_to.x, g.hex_to_move_to.y)
			//println('moving_unit_x=$g.moving_unit_x dest_x=$dest_x')
			// End of movement, reached the destination
			if g.moving_unit_x >= dest_x - 100 { // && g.moving_unit_y >= dest_y {
				g.units[i].anim_state = .wait
				g.units[i].x = g.hex_to_move_to.x
				g.units[i].y = g.hex_to_move_to.y
				g.moving_unit_x = 0
				g.moving_unit_y = 0
			}
		}
		k := int(unit.kind)
		anim_i := g.anim_i // g.frame / 12 // which sprite frame to render
		kind := unit.anim_state // AnimKind.hover
		nr_anims := unit.sprites[kind].len
		// println(nr_anims)
		if unit.side == .left {
			x := if unit.anim_state == .move { g.moving_unit_x } else {  unit.x * hex_width }
			y := if unit.anim_state == .move { g.moving_unit_y } else { unit.y * unit_vpadding / 2  } //* i_left }
			g.gg.draw_image(x - 100, y - 130, 450, 400, unit.sprites[kind][anim_i % nr_anims])
			i_left++
		} else if unit.side == .right {
			y := unit_vpadding * i_right
			g.gg.draw_image_flipped(460, y - 130, 450, 400, unit.sprites[kind][anim_i % nr_anims])
			i_right++
		}
		// Box with the number of units (don't display it when the unit is moving)
		if unit.anim_state in [.wait, .hover] {
			mut count_x := 120 + unit.x * hex_height
			if unit.info.large {
				if unit.side == .left {
					count_x += 40
				} else {
					count_x -= 40
				}
			}
			count_y := 115 + unit.y * (hex_height + 10)
			g.gg.draw_rect(count_x, count_y, 22, 9, unit_number_bg_color)
			g.gg.draw_empty_rect(count_x, count_y, 22, 9, unit_number_border_color)
			g.gg.draw_text(count_x + 8, count_y - 1, '$unit.count', {
				color: gx.white
				size: 10
			})
		}
	}
	// anim_x += 10
}

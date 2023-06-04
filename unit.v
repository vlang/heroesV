module main

import gg
import os

struct Unit {
	kind    UnitKind
	info    UnitInfo
mut:
	side UnitSide
	sprites [][]gg.Image
	anim_state AnimKind = .wait
	count int = 1
	x int // position on the battlefield grid
	y int
}

fn (u Unit) name() string {
	return unit_names[u.kind]
}

enum UnitKind {
	// castle
	sword // 4
	crusader
	monk // 5
	zealot
	angel // 7
}

enum UnitSide {
	left
	right
}

enum AnimKind {
	move = 0
	hover = 1
	wait = 2
	attacked = 3
	attacked_def = 4
	killed = 5
	xx = 6
	yy = 7
	zz = 8
	qq = 9
	ww = 10
	attack_top = 11
	attack_straight = 12
	attack_bottom = 13
	x1 = 14
	x2 = 15
	x3 = 16
	x4 = 17
	x5 = 18
	x6 = 19
	x7 = 20
	x8 = 21
}

struct UnitInfo {
	health  int
	attack  int
	defense int
	speed   int
	large bool // occupies 2 hexes
	// nr_anims int
}

const (
	unit_names    = init_names()
	unit_infos    = init_stats()
	nr_animations = 3 // 22
	nr_units      = 10
	unit_vpadding = 82 // vertical distance between units on the battlefield
)

fn (mut g Game) new_unit(kind UnitKind) Unit {
	mut unit := Unit{
		kind: kind
		info: unit_infos[kind]
	}
	// load sprites
	unit.sprites = [][]gg.Image{len: nr_animations}
	println('loading sprites for ' + unit.name())
	dir := 'anim/c${unit.name()}.dir'
	for i in [0, 1, 2] { // 0..nr_animations {
		mut len := 0
		for j in 0 .. 20 {
			path := '$dir/${i:02d}_${j:02d}.png'
			// println(path)
			if !os.exists(path) {
				len = j
				break
			}
		}
		unit.sprites[i] = []gg.Image{len: len}
		for j in 0 .. len {
			path := '$dir/${i:02d}_${j:02d}.png'
			unit.sprites[i][j] = g.gg.create_image(path)
		}
	}
	return unit
}

fn init_names() []string {
	mut n := []string{len: nr_units}
	// castle
	n[UnitKind.sword] = 'sword'
	n[UnitKind.crusader] = 'crusd'
	n[UnitKind.monk] = 'monkk'
	n[UnitKind.zealot] = 'zealt'
	n[UnitKind.angel] = 'rangl'
	return n
}

fn init_stats() []UnitInfo {
	mut n := []UnitInfo{len: nr_units}
	n[UnitKind.angel] = {
		health: 200
		attack: 40
		defense: 40
		speed: 12
		large: true
	}
	n[UnitKind.monk] = {
		health: 200
		attack: 40
		defense: 40
		speed: 12
	}
	n[UnitKind.sword] = {
		health: 200
		attack: 40
		defense: 40
		speed: 12
	}
	n[UnitKind.crusader] = {
		health: 200
		attack: 40
		defense: 40
		speed: 12
	}
	n[UnitKind.zealot] = {
		health: 200
		attack: 40
		defense: 40
		speed: 12
	}
	// n[UnitKind.monk] = 'monkk'
	// n[UnitKind.sword] = 'sword'
	// n[UnitKind.zealot] = 'zealt'
	return n
}

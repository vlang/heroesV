import os
import filepath

fn main() {
	files := os.walk_ext('.', 'bmp')
	for file in files {
		png := file.all_before('.bmp') + '.png'
		os.system('convert $file $png')
		os.system('convert $png -transparent cyan $png')
	}
	//println(files)
}


import os
fn main(){
lines := os.read_lines('/Users/alex/Library/Application Support/CrossOver/Bottles/hota3/drive_c/Games/Heroes3_HotA2/HotA_RMGTemplates/Jebus King 2.5/rmg.txt') ?
for line in lines {
	words := line.split('\t')
	for w in words {
		word := w.trim_space()
		if word == '' {
			continue
		}
		println(word)
	}
	println('================')
}
}

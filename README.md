# random_pentomino

Idea from https://twitter.com/nosiika/status/1609025773817724930

> ｎ×ｎのマス目をランダムに黒く塗っていく。
黒マスが5マス繋がった段階でそれがペントミノ12種類の内のどれか調べる（6マス越えていたら無視してリセット）。
できるペントミノをできやすい順に並べたら、どんな感じに並ぶだろう？

> Paint n*n cells in random order.
As soon as 5 cells are connected, detect which of the 12 type of pentomino is made. (If more than 6 cells are connected, ignore and reset.)
List the types of pentomino in order by their occurrence rate.

#### todo
- Profile the performance and consider faster algorithm
	- pentomino type detection
	- reuse Object
	- reuse random sequence (re-shuffle only the used part)
- Consider using faster programming language
	- C ?
	- Julia ?
- Make result visualiser
	- Excel PowerQuery + Pivot chart ?
	- D3.js ?

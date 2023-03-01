Red [
	Needs: View
	Author: "Toomas Vooglaid"
	Licence: "BSD-3"
	Date: 1-Mar-2023
]
glass: 0.0.0.255 - 1 
zmin: 1
zmax: 10
zcur: 3.0
zval: 0.23
zcur1: zcur - 1
mgsz: 94x94
dim: 'both
gmax: 180
gmin: 20
gcur: 94
gval: 0.46
shape: 'round
type:  'image
make-glass: does [
	mghsz: mgsz / 2
	mzx: mgsz/x / zcur1
	mzy: mgsz/y / zcur1
	frame: mghsz + 3
	p1: either shape = 'round [frame * cosine 45][frame + 2]
	p2: p1 + 30
	p3: p1 + 15
	point: as-pair 0 mghsz/y
]
make-glass
dummy: make-face/size 'rich-text 500x100
get-img: func [file [file! url! string! none!]][
	either string? file [
		img: rtd-layout compose [f 5 (file) /f]
		dummy/text: file
		sz: min 500x500 size-text dummy
		img/size: sz
	][
		img: load any [file https://avatars.githubusercontent.com/u/4625645?s=200&v=4];%../drawing/red-logo-1.png] 
		sz: img/size
	]
	ofs: sz / 2 + p3 
	ofs2x: hszx: sz/x / 2
	ofs2y: hszy: sz/y / 2
	img
]
get-img none
recalculate: func [ofs0][
	ofs: max (p3) min (sz + p3) ofs0             ;restrict MG movement
	ofs2: ofs - p3
	ofs2x: zm/draw/matrix/5: ofs2/x              ;move MG
	ofs2y: zm/draw/matrix/6: ofs2/y
	ofs3x: zcur1 * negate mzx + ofs2x            ;compensate zoomed offset to center of MG
	ofs3y: zcur1 * negate mzy + ofs2y
	zm/draw/3/push/matrix/5: ofs3x + mgsz/x - ofs2x
	zm/draw/3/push/matrix/6: ofs3y + mgsz/y - ofs2y
	show zm
]
template: round-template: [
	matrix [1 0 0 1 (ofs2x) (ofs2y)][
		pen coal line-width 6 
		ellipse (negate frame) (2 * frame)
		line-width 8 line-cap round line (p1) (p2)
		push [
			clip [
				move (point) 
				arc (0 - point) (mghsz/x) (mghsz/y) 0 
				arc (point)     (mghsz/x) (mghsz/y) 0
			] 
			matrix [(zcur) 0 0 (zcur) (ofs2x) (ofs2y)] [image img]
		]
		pen off fill-pen radial 0.0.0.255 0.0.0.240 0.0.0.200 1.0 
		ellipse (0 - mghsz) (mgsz) 
	]
]
rect-template: [
	matrix [1 0 0 1 (ofs2x) (ofs2y)][
		pen coal line-width 6 
		;shadow -5x5 5 0 128.128.128
		box (negate frame) (frame) 
		line-width 8 line-cap round line (p1) (p2)
		push [
			clip [
				move (negate mghsz)
				hline (mghsz/x) vline (mghsz/y) hline (0 - mghsz/x) vline (0 - mghsz/y)
			]
			matrix [(zcur) 0 0 (zcur) (ofs2x) (ofs2y)] [image img]
		]
		pen off fill-pen radial 0.0.0.255 0.0.0.240 0.0.0.200 1.0 
		box (0 - mghsz) (mghsz) 
	]
]
pic: compose/deep template
new-image: func [face][
	im/size: zm/size: bx/size: sz
	pan/offset/y: im/offset/y + sz/y + 10
	face/size: as-pair 20 + max im/size/x pan/size/x 
					   10 + pan/offset/y + pan/size/y
	zm/draw: compose/deep template
	recalculate ofs
	show lay
]
render-image: func [file][
	type: 'image
	img: get-img file 
	im/draw: [image img]
	template/3/push/5: [image img]
	new-image lay
]
render-text: func [file][
	type: 'text
	img: get-img read file
	im/draw: compose [text 0x0 (img)]
	template/3/push/5: [pen off fill-pen white box 0x0 (sz) text 0x0 (img)]
	new-image lay
]
render-glass: func [what][
	shape: what
	switch shape [
		round [template: round-template]
		rect  [template: rect-template]
	]
	switch type [
		image [template/3/push/5: [image img]]
		text  [template/3/push/5: [pen off fill-pen white box 0x0 (sz) text 0x0 (img)]]
	]
	make-glass
	zm/draw: compose/deep template
	recalculate ofs2 + p3
]
ask-url: function [type [string!]][
	tx: rejoin ["Please enter URL of " type "!"]
	view [
		title tx
		f: field 400 focus return 
		button "OK" [out: f/data unview]
		button "Cancel" [unview]
	]
	out
]
ask-limits: function ['mn 'mx 'cr][
	min: get mn 
	max: get mx
	cur: get cr
	view lim: layout [
		text 20 "Min:" f1: field 50 data min
		text 20 "Max:" f2: field 50 data max
		text 45 "Current:" f3: field 50 data cur
		return
		button "OK" [
			either all [
				number? f1/data 
				number? f2/data 
				number? f3/data 
				f1/data < f2/data
				f3/data >= f1/data 
				f3/data <= f2/data
			][
				set mn f1/data 
				set mx f2/data 
				set cr f3/data 
				val: (f3/data - f1/data) / (f2/data - f1/data)
				switch mn [
					gmin [gval: slg/data: val slg/actors/on-change slg none]
					zmin [zval: slz/data: val slz/actors/on-change slz none]
				]
				show lay
				unview
			][lim/text: "Please check your data!" show lim]
		]
	]
]
system/view/auto-sync?: off
view/flags/options/no-wait lay: layout compose/deep [
	title "Magnifying glass"
	im: rich-text (sz) draw [image (img)] 
	at 10x10 zm: rich-text (sz) transparent focus draw pic
		on-key-down [
			switch event/key [
				right [recalculate ofs: ofs + 5x0]
				left  [recalculate ofs: ofs + -5x0]
				up    [recalculate ofs: ofs + 0x-5]
				down  [recalculate ofs: ofs + 0x5]
			]
		]
	at 10x10 bx: box glass (sz) 
		all-over
		on-down [recalculate ofs: event/offset] 
		on-over [if event/down? [recalculate ofs: event/offset]]
		on-up   [set-focus zm show lay]
	return 
	pan: panel [origin 0x0 
		txz: text "Zoom:" 37 
		slz: slider 110 data zval [
			zval: face/data
			zm/draw/3/push/matrix/1: zm/draw/3/push/matrix/4:
			zcur: zmax - zmin * zval + zmin
			zcur1: zcur - 1
			mzx: mgsz/x / zcur1
			mzy: mgsz/y / zcur1
			recalculate ofs 
			ztx/text: form round/to zcur 0.1 
			show [ztx zm]
		] 
		ztx: text 25 with [text: form zcur]
		return txg: text "Glass:" 37
		slg: slider 110 data gval [
			gval: face/data
			gcur: round/to gmax - gmin * gval + gmin 1
			switch dim [
				x    [mgsz/x: gcur]
				y    [mgsz/y: gcur]
				both [mgsz: to-pair gcur]
			]
			make-glass
			zm/draw: compose/deep template
			recalculate ofs: p3 + ofs2
			gtx/text: form gcur
			show [zm gtx]
		] 
		on-up [recycle] 
		on-key-down [
			switch event/key [
				#"X" [txg/text: "X:" show txg dim: 'x]
				#"Y" [txg/text: "Y:" show txg dim: 'y]
				#" " [txg/text: "Glass:" show txg dim: 'both]
			]
		]
		gtx: text 25 with [text: form gcur]
	]
][no-min no-max][
	menu: [
		"Image" [
			"Image File" file
			"Image URL"  url
			"Text File"  text
			"Text URL"   net
		]
		"Options" [
			"Glass shape" [
				"Round"     round
				"Rectangle" rect
			]
			"Glass limits"  glim
			"Zoom limits"   zlim
		]
	]
	actors: context [
		on-down: func [f e][set-focus zm show lay]
		on-menu: func [face event][
			switch event/picked [
				file  [if file: request-file    [render-image file]]
				url   [if file: ask-url "image" [render-image file]]
				text  [if file: request-file    [render-text  file]]
				net   [if file: ask-url "text"  [render-text  file]]
				round [render-glass 'round]
				rect  [render-glass 'rect]
				zlim  [zcur: round/to zcur 0.1 ask-limits zmin zmax zcur]
				glim  [ask-limits gmin gmax gcur]
			]
		]
	]
]
recalculate ofs
do-events

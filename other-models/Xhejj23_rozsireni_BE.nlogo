breed [people person]
breed [exits exit]
breed [obstacles obstacle]
breed [windows window]
breed [walls wall]
breed [waterdrops waterdrop]

people-own [pace headx heady stumbled brave life]
exits-own [doorx doory]
obstacles-own [material obstaclex obstacley]
windows-own [windowx windowy]
walls-own [wallx wally alignment]
waterdrops-own [waterdx waterdy]

globals [escaped-people burned-people crushed-people jumpOK-people jumpKO-people min-exit fire_tile count_fire_alarm]

to setup
  clear-all
  reset-ticks
  setup-exits
  setup-windows
  setup-obstacles
  setup-walls
  setup-room

  setup-people
  blow-up
end

to go

  make-step
  stumble
  escape
  jump-out
  crush
  fire-spread
  burn
  tick

end

to make-step

  ask people [
    facexy headx heady
    if stumbled = true [;if stumbled pace 0.01
      set pace 0.01
      ]
    if wall_on = true [ ;setting directions if wall is on
      if ((xcor > 27 and xcor < 37) and (ycor > 27 and ycor < 32))[
        let direction random 100
        if direction < 50 [ ;ensuring splitting at the end of wall that half would go left and half right
          set headx 30
          set heady 0
      ]
        if direction >= 50[
          set headx 34
          set heady 0
        ]
      ]
    if ((xcor > 27 and xcor < 31) and (ycor > 0 and ycor < 3))[
        set headx 1
        set heady 1
      ]
    if ((xcor >= 32 and xcor < 37) and (ycor > 0 and ycor < 3))[
        ifelse count_of_exits >= 2[ ;if count of exits is not one, split people else set exit0
          set headx 63
          set heady 1
        ]
        [
          set headx 1
          set heady 1
          ]
      ]

    ]
    if people_running = true [ ; if people are running set pace * 1.25
      set pace pace * 1.25
      ]
    ifelse avoid_fire_tiles = true [ ; help to ensure avoiding red tiles (tiles with fire)
      set fire_tile red
      ]
    [set fire_tile yellow ; movement of person - trying go ahead, if not posible left and right in angle 45, if not trying left and right in angle 90, if not trying go backwards, angle 180
      ]
    ifelse (patch-ahead pace != nobody) and ((not any? turtles-on patch-ahead pace) or ((count turtles-on patch-ahead pace = 1) and (one-of turtles-on patch-ahead pace = self))) and ([pcolor] of patch-ahead pace != grey) and ([pcolor] of patch-ahead pace != white) and ([pcolor] of patch-ahead pace != brown) and ([pcolor] of patch-ahead pace != fire_tile) [
      jump pace
      ] [
      ifelse (patch-right-and-ahead 45 pace != nobody) and (not any? turtles-on patch-right-and-ahead 45 pace) and ([pcolor] of patch-right-and-ahead 45 pace != grey) and ([pcolor] of patch-right-and-ahead 45 pace != white) and ([pcolor] of patch-right-and-ahead 45 pace != brown) and ([pcolor] of patch-right-and-ahead 45 pace != fire_tile) [
        right 45
        jump pace
        ] [
        ifelse (patch-left-and-ahead 45 pace != nobody) and (not any? turtles-on patch-left-and-ahead 45 pace) and ([pcolor] of patch-left-and-ahead 45 pace != grey) and ([pcolor] of patch-left-and-ahead 45 pace != white) and ([pcolor] of patch-left-and-ahead 45 pace != brown) and ([pcolor] of patch-left-and-ahead 45 pace != fire_tile) [
            left 45
            jump pace
            ] [
        ifelse (patch-right-and-ahead 90 pace != nobody) and (not any? turtles-on patch-right-and-ahead 90 pace) and ([pcolor] of patch-right-and-ahead 90 pace != grey) and ([pcolor] of patch-right-and-ahead 90 pace != white) and ([pcolor] of patch-right-and-ahead 90 pace != brown) and ([pcolor] of patch-right-and-ahead 90 pace != fire_tile) [
          right 90
          jump pace
        ] [
        ifelse (patch-left-and-ahead 90 pace != nobody) and (not any? turtles-on patch-left-and-ahead 90 pace) and ([pcolor] of patch-left-and-ahead 90 pace != grey) and ([pcolor] of patch-left-and-ahead 90 pace != white) and ([pcolor] of patch-left-and-ahead 90 pace != brown) and ([pcolor] of patch-left-and-ahead 90 pace != fire_tile) [
          left 90
          jump pace
          ] [
          ifelse (patch-left-and-ahead 180 pace != nobody) and (not any? turtles-on patch-left-and-ahead 180 pace) and ([pcolor] of patch-left-and-ahead 180 pace != grey) and ([pcolor] of patch-left-and-ahead 180 pace != white) and ([pcolor] of patch-left-and-ahead 180 pace != brown) and ([pcolor] of patch-left-and-ahead 180 pace != fire_tile)[
            left 180
            jump pace
          ]
          [
            ifelse (patch-right-and-ahead 180 pace != nobody) and (not any? turtles-on patch-right-and-ahead 180 pace) and ([pcolor] of patch-right-and-ahead 180 pace != grey) and ([pcolor] of patch-right-and-ahead 180 pace != white) and ([pcolor] of patch-right-and-ahead 180 pace != brown) and ([pcolor] of patch-right-and-ahead 180 pace != fire_tile) [
              right 180
              jump pace
          ]
            [ forward -1 * pace
              ]
            ]
          ]
        ]
      ]
        ]
    if people_running = true [ ;decreasing pace when running, if it would not be here, the pace will go faster and faster every tick
      set pace pace / 1.25  ]
    ]
  ]
end

to stumble ; setting by random value if people stumbled
  if people_running = true [
  ask people[
    if random 1000 < 0.5 [
      set stumbled true
    ]
  ]
  ]
end

to crush

  ask people [
    ask patch-here [
      if count turtles-on neighbors >= 6 and random 100 < 5 [
        ask myself [
          set crushed-people crushed-people + 1
          die
          ]
        ]
      ]
    ]

end

to burn

  ask people [

    ask patch-here[
      if avoid_fire_tiles = true[
      if any? neighbors with [pcolor = red] [ ; decreasing life while next to fire tile
        ask myself[
          set life life - 1
          if life = 0 [
            set burned-people burned-people + 1
            die
        ]
        ]
        ]
      ]
      if pcolor = red [
        ask myself [
          set burned-people burned-people + 1
          die
          ]
        ]

      ]
]
end

to escape
  ask people[
    ask patch-here[
      if (pcolor = green) [
        ask myself [
          set escaped-people escaped-people + 1
          die
          ]
        ]
      ]
    ]
end

to jump-out ; jumping out of window. Further random value whether the tarp is ready
  ask people[
    ask patch-here[
      if (pcolor = blue + 4) [
        ask myself [
          let tarp-ready random 100
          ifelse tarp-ready < 10[
            set jumpKO-people jumpKO-people + 1
            die
            ]
          [
            set jumpOK-people jumpOK-people + 1
            die
            ]
          ]
        ]
      ]
    ]
end

to fire-spread

  ask patches [
    if pcolor = red [
      if random 100 < 2 [
        set pcolor black
        ]
      ]
    if pcolor = grey and any? neighbors with [pcolor = red] [ ;rules for spreading of fire through obstacles. Random value with set probability
      if random 500 < 5 [
        set pcolor red
        ]
      ]
    if pcolor = white and any? neighbors with [pcolor = red] [
      if random 500 < 15 [
        set pcolor red
        ]
      ]
    if pcolor = brown and any? neighbors with [pcolor = red] [
      if random 500 < 20 [
        set pcolor red
        ]
      ]
    if pcolor = brown + 4 and any? neighbors with [pcolor = red] [
      if random 100 < 5 [
        set pcolor red
        ]
      ]
    if pcolor = green and any? neighbors with [pcolor = red] [
      if random 500 < 2 [
        set pcolor red
        ]
      ]

    ]

end

to fire_alarm
  if count_fire_alarm < 1[
  make-water-alarm
  ask patches[
    let x pxcor
    let y pycor

    ask waterdrops[
      if (x > (waterdx - 0)) and (x < (waterdx + 1)) and (y > (waterdy - 1)) and (y < (waterdy + 1)) [
        ask myself [
          set pcolor blue]
      ]
      ]
    ]]
  set count_fire_alarm count_fire_alarm + 1
end

to make-water-alarm
  create-waterdrops 120
  [
    set waterdx random-xcor
    set waterdy random-pycor
    setxy waterdx waterdy
    set size 1
    set color blue
    hide-turtle
  ]
end


to setup-room

  ask patches [
    set pcolor brown + 4

    let x pxcor
    let y pycor
    let help_material 0
    ask exits [
      if (x > (doorx - 2)) and (x < (doorx + 2)) and (y > (doory - 2)) and (y < (doory + 2)) [
        ask myself [
          set pcolor green]
      ]

    ]
    ask windows [ ; painting up the window with blue color
      if (x > (windowx - 2)) and (x < (windowx + 2)) and (y > (windowy - 2)) and (y < (windowy + 2))[
      ask myself [
        set pcolor blue + 4]
        ]
      ]

    ask obstacles[ ; painting up the obstacles with a color coresponding to material
      if (x > (obstaclex - obstacle_size)) and (x < (obstaclex + obstacle_size)) and (y > (obstacley - obstacle_size)) and (y < (obstacley + obstacle_size))[
        if material = "concrete" [
          set help_material 1
          ]
        if material = "pvc"[
          set help_material 2
          ]
        if material = "wood"[
          set help_material 3
          ]
      ask myself [
        if help_material = 1 [
          set pcolor grey
          ]
        if help_material = 2[
          set pcolor white
          ]
        if help_material = 3[
          set pcolor brown
          ]
        ]
        ]
      ]
    if wall_on = true [ ; if walls are on, painting the walls for a path to exits0 and 1
      ask walls [
        if alignment = 0 [
          if (x > (wallx - 1)) and (x < (wallx + 1)) and (y > (wally - 22)) and (y < (wally + 2)) [
            ask myself [
              set pcolor grey]
      ]]
        if alignment = 1[
          if (x > (wallx - 28)) and (x < (wallx + 1)) and (y > (wally - 1)) and (y < (wally + 1)) [
            ask myself [
              set pcolor grey]
      ]
          ]
        if alignment = 2[
          if (x > (wallx - 1)) and (x < (wallx + 28)) and (y > (wally - 1)) and (y < (wally + 1)) [
            ask myself [
              set pcolor grey]
      ]
          ]
    ]

      ]
    ]

end

to setup-walls ; setting walls, coordinates and alignment
  if wall_on = true [
  create-walls 4

  ask wall (count exits + count windows + count obstacles ) [
    set wallx 27
    set wally 25
    set alignment 0
    ]
  ask wall (count exits + count windows + count obstacles + 1 ) [
    set wallx 37
    set wally 25
    set alignment 0
    ]
  ask wall (count exits + count windows + count obstacles + 2 ) [
    set wallx 27
    set wally 3
    set alignment 1
  ]
  ask wall (count exits + count windows + count obstacles + 3 ) [
    set wallx 37
    set wally 3
    set alignment 2
  ]
  ask walls [
    setxy wallx wally
    hide-turtle
    ]
  ]
end

to setup-obstacles
  create-obstacles count_of_obstacles

  ask obstacles [
    let matobst random 100
    set obstaclex random-pxcor
    set obstacley random-pycor
    if wall_on = true[
      if obstacley < 7 [
        set obstacley obstacley + 7
      ]
      if ((obstaclex > 27) and (obstaclex < 37)) and ((obstacley <= 25) and (obstacley >= 3)) [ ;ensuring that obstacle will not be in a way of walls
        set obstaclex obstaclex - 10
      ]
    ]
    if matobst >= 33 and matobst < 66 [ ; setting the material type
      set material "concrete"
      ]
    if matobst < 33 [
      set material "pvc"
      ]
    if matobst >= 66 [
      set material "wood"
      ]
    setxy obstaclex obstacley
    set shape "square"
    hide-turtle
    ]
end

to setup-windows
  create-windows 1

  ask windows [
    set windowx 32
    set windowy 63
    setxy windowx windowy
    hide-turtle
    ]
end

to setup-exits

  create-exits count_of_exits ; creating exits and coordinates of each exit
  if count_of_exits = 1 [
  ask exit 0 [
    set doorx 1
    set doory 1
    ]
  ]
  if count_of_exits = 2 [
  ask exit 0 [
    set doorx 1
    set doory 1
    ]
  ask exit 1 [
    set doorx 63
    set doory 1
    ]
  ]
  if count_of_exits = 3 [
  ask exit 0 [
    set doorx 1
    set doory 1
    ]
  ask exit 1 [
    set doorx 63
    set doory 1
    ]
  ask exit 2 [
    set doorx 1
    set doory 63
    ]
  ]
  if count_of_exits = 4 [
  ask exit 0 [
    set doorx 1
    set doory 1
    ]
  ask exit 1 [
    set doorx 63
    set doory 1
    ]
  ask exit 2 [
    set doorx 1
    set doory 63
    ]
  ask exit 3 [
    set doorx 63
    set doory 63
    ]
  ]
  ask exits [
    setxy doorx doory
    hide-turtle
    ]

end


to setup-people

  create-people persons

  ask people [
    move-to one-of patches with [ pcolor = brown + 4 ]
    set size 2
    set pace random-normal 1 0.2
    set stumbled false
    set brave random 100
    set life random-normal 2 1

    let min-dist 1000000


    ifelse brave < 1 [ ;setting way to window and jump out of it
      ask windows [
        set min-exit self
        ]
      set headx [windowx] of min-exit
      set heady [windowy] of min-exit
      ]
    [
    ask exits [
      if distance myself < min-dist [
        set min-dist distance myself
        set min-exit self
        ]
      ]
    set headx [doorx] of min-exit
    set heady [doory] of min-exit
    ]
    if wall_on = true [ ; if wall is on, setting coordinates to go to the entry
      if ((headx = 1 and heady = 1) or (headx = 63 and heady = 1)) and (ycor > 3) and ((xcor < 27) or (xcor > 37))[
        set headx 32
        set heady 28
      ]
      if (((headx = 1 and heady = 1) or (headx = 63 and heady = 1)) and ((ycor > 3) and (ycor < 25)) and ((xcor > 27) and (xcor < 37)))[
        set headx 32
    set heady 0
      ]
    ]
  ]
end

to blow-up

  let firex random-xcor
  let firey random-xcor

  ask patches [
    if ((firex - pxcor) ^ 2 + (firey - pycor) ^ 2 <= 10) [
        set pcolor red
        ]

    ]

end
@#$#@#$#@
GRAPHICS-WINDOW
485
71
1015
622
-1
-1
8.0
1
10
1
1
1
0
0
0
1
0
64
0
64
1
1
1
ticks
30.0

BUTTON
38
61
101
94
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
39
134
102
167
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
229
54
384
114
persons
750
1
0
Number

MONITOR
1315
96
1416
141
NIL
escaped-people
17
1
11

MONITOR
1316
168
1414
213
NIL
crushed-people
17
1
11

MONITOR
1318
233
1412
278
NIL
burned-people
17
1
11

MONITOR
1144
96
1300
141
NIL
escaped-people / persons
17
1
11

MONITOR
1144
167
1298
212
NIL
crushed-people / persons
17
1
11

MONITOR
1145
231
1294
276
NIL
burned-people / persons
17
1
11

SLIDER
229
165
401
198
count_of_exits
count_of_exits
1
4
3
1
1
NIL
HORIZONTAL

SLIDER
230
237
402
270
count_of_obstacles
count_of_obstacles
0
20
8
1
1
NIL
HORIZONTAL

SWITCH
230
471
371
504
people_running
people_running
1
1
-1000

PLOT
1145
383
1487
610
Count of people during simulation
ticks
people
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"escaped-people" 1.0 0 -13791810 true "" "plot escaped-people"
"burned-people" 1.0 0 -2674135 true "" "plot burned-people"
"crushed-people" 1.0 0 -6459832 true "" "plot crushed-people"
"to-rescue" 1.0 0 -16777216 true "" "plot (persons - escaped-people - crushed-people - burned-people - jumpOK-people - jumpKO-people)"

MONITOR
1453
95
1550
140
NIL
jumpOK-people
17
1
11

MONITOR
1453
170
1550
215
NIL
jumpKO-people
17
1
11

SLIDER
231
313
403
346
obstacle_size
obstacle_size
1
10
4
1
1
NIL
HORIZONTAL

SWITCH
232
397
335
430
wall_on
wall_on
1
1
-1000

SWITCH
232
547
372
580
avoid_fire_tiles
avoid_fire_tiles
0
1
-1000

MONITOR
1145
300
1358
345
Count of people to-rescue (in system)
persons - escaped-people - crushed-people - burned-people - jumpOK-people - jumpKO-people
17
1
11

BUTTON
40
237
127
270
NIL
fire_alarm
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
32
30
182
58
Spuštění inicializační sekvence (nastavení prostředí)
11
0.0
1

TEXTBOX
36
102
186
130
Spuštění vlastní simulace (průběhu)
11
0.0
1

TEXTBOX
231
31
381
49
Nastavení počtu lidí v simulaci
11
0.0
1

TEXTBOX
231
129
381
157
Nastavení počtu únikových východů
11
0.0
1

TEXTBOX
232
213
382
231
Nastavení počtu překážek
11
0.0
1

TEXTBOX
232
290
401
318
Nastavení šířky/velikosti překážek
11
0.0
1

TEXTBOX
38
190
188
232
Spuštění požárního alarmu (dostupný pouze jednou za simulaci)
11
0.0
1

TEXTBOX
234
358
384
386
Nastavení chodby k východům 1 a 2
11
0.0
1

TEXTBOX
233
446
383
464
Nastavení, zdali lidé běží
11
0.0
1

TEXTBOX
234
522
384
540
Vyhýbání se políčkům s ohněm
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@

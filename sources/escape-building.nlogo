globals
[
  count-random-move-limit ;;how many consecutively random moves resets visited-patches (no door find yet)
  exiting-door-limit ;;how many steps is person exiting door
  check-door-limit ;; how many steps we check if next-door is still in sight
  freed ;;count freed people
  current-tool door-orientation ;; variables needed to be compatible with editor (import without errors)
]

Breed [people person]
Breed [corpses corpse]

turtles-own
[

  move-steps ;;count steps, resets after being stuck (see is-stuck-limit global)
  next-door ;;next door to go to
  exiting-door ;;exiting-door counter (see exiting-door-limit global)
  count-random-move ;; count-random-move counter (see count-random-move-limit global)
  visited-patches ;; list of visited-patches
  prev-patch ;; previous visited patch
  pressure ;; pressure
  ;;;
  door-patches
  visited-door-patches
  prev-door
]
patches-own
[
  is-door ;;is patch door
]

;;init setup
to setup

  clear-globals
  clear-ticks
  clear-turtles
  clear-drawing
  clear-all-plots
  clear-output
  reset-ticks
  setup-globals
  setup-people
  setup-patches

end

;;setup patches variables
to setup-patches
  ask patches
  [
   ifelse pcolor = red or pcolor = green or pcolor = cyan
   [
      set is-door true
    ]
    [
      set is-door false
    ]
  ]
end

;;setup-globals
to setup-globals
  set count-random-move-limit  60
  set exiting-door-limit 10
  set check-door-limit 80
end

;;setup-people
;;setup init variables and distribute them into building
to setup-people
  set-default-shape turtles "circle"
  let targetedGroup patches with [pcolor = brown]
  ask n-of people-count targetedGroup
  [ sprout 1
    [
      set breed people
      set color white
      set size 1
      set visited-patches (list)
      set prev-patch patch-here
      set pressure 0
      set exiting-door 0
      set move-steps 0
      set next-door nobody
      set prev-door (list)
    ]
  ]
end

to go2
  ;;simulation if there are not any people remaining
  if not any? people
  [
    stop
  ]
  ask people
  [
;;set exiting-door if we stepped out of door
    if member? next-door prev-door
    [
     set visited-patches (list prev-door)
    ]
    if [is-door] of prev-patch = true
    [
     ;;output-print(word self " starts exiting")
       set exiting-door exiting-door-limit
    ]

    ;;go outside of building (black patch)
    ifelse pcolor = cyan
    [
      let patch-to min-one-of patches with [ pcolor = black] [distance myself]
      make-move patch-to
    ]
    [
      ;;if outside, person is freed
      ifelse pcolor = black
      [
      set freed freed + 1
      die
      ]
      [
       ifelse is-door = true or exiting-door > 0
       [
          if next-door != nobody
          [
            face next-door
            set prev-door (list)
            ;;output-print(word self " getting prev-door " )
            put-patch-to-prev-door next-door
            set next-door nobody
          ]
          make-move-random 10
          if exiting-door > 0
          [
                ;;output-print(word self " exiting door " exiting-door)

            set exiting-door exiting-door - 1
          ]
        ]
        [
          ifelse next-door = nobody
          [
            set door-patches (list)
            set visited-door-patches (list)
            if find-door-in-room patch-here []
            ;;if length door-patches = 0 [ output-print(word self " " door-patches) ]
            let tmp filter [ i -> not member? i visited-patches ] door-patches
            ;;output-print(word self " " tmp)
            let tmp2 sort-by sort-by-color tmp
            ;;output-print(word self " " tmp2)
            ifelse length tmp2 = 0
            [
             set tmp2 sort-by sort-by-color door-patches
              ifelse length tmp2 = 0
              [
                make-move-random 15
                set count-random-move count-random-move  + 1
              ]
              [

                                set next-door item 0 (tmp2)
                make-move next-door
                set count-random-move 0
              ]

            ]
            [

              set next-door item 0 (tmp2)
              make-move next-door
              set count-random-move 0
            ]



          ]
          [
            ifelse patch-here = next-door
            [
              set next-door nobody
            ]
            [
              make-move next-door
            ]

          ]
        ]
      ]
    ]

    put-patch-to-visited patch-here
    set prev-patch patch-here
  ]
  tick
end
;;go
to go



  ;;simulation if there are not any people remaining
  if not any? people
  [
    stop
  ]

  ask people
  [

    ;;if [pcolor] of patch-here = blue [ output-print(word self " stepped on blue") ]
    ;; output-print(word self " " prev-patch " " pcolor " " [isDoor] of prev-patch)

    ;;set exiting-door if we stepped out of door
    if [is-door] of prev-patch = true
    [
    ;; output-print(word self " is exiting")
       set exiting-door exiting-door-limit
    ]

    ;;go outside of building (black patch)
    ifelse pcolor = yellow
    [
      let patch-to min-one-of patches with [ pcolor = black] [distance myself]
      make-move patch-to
    ]
    [
      ;;if outside, person is freed
      ifelse pcolor = black
      [
      set freed freed + 1
      die
      ]

    [
        if patch-ahead 1 != nobody
        [


          ;;if person is in door or is exiting door go straight
            ifelse is-door = true or exiting-door > 0
            [


              make-move-random 10
              if exiting-door > 0
              [
                ;;output-print(word self " exiting door " exiting-door)

                set exiting-door exiting-door - 1
              ]
            ]
            [
            ;;we have not found door to go to yet
            ;;find nearest door by priority (yellow, green, red) if not found, go random
            ifelse next-door = nobody
            [

              let find-door (move-to-door yellow visited-patches)

              ifelse (find-door = false)
              [
                set find-door (move-to-door green visited-patches)
                ifelse (find-door = false)
                [
                  set find-door (move-to-door red visited-patches)
                  ifelse (find-door = false)
                  [
                    ;;output-print(word self " random move")
                    make-move-random 10
                    set count-random-move count-random-move + 1
                    ;;reset visited-patches if we cannot find door
                    if count-random-move = count-random-move-limit
                    [
                      set visited-patches (list)
                      set prev-patch patch-here
                    ]
                  ]
                  [
                    set count-random-move 0
                  ]
                ]
                [
                  set count-random-move 0
                ]
              ]
              [
                set count-random-move 0
              ]
            ]
            ;;we have found next-door
            [
              ;;output-print(word self " is door " [isDoor] of next-door)

              ;;try to find better door (better-door priority > next-door priority)
              if find-better-next-door = false
              [
                ;;output-print(word self " found better door " next-door)
                make-move next-door
                ;;make-move-random 15

                ;;checks if the door is still in sight periodically
                if move-steps > check-door-limit
                [
                  if is-in-line-of-sight next-door = false
                  [
                    set next-door nobody
                    ;;set visited-patches (list patch-here)
                  ]
                  set move-steps 0
                ]

              ]
              ;;we got to the destination, reset next-door
              if patch-here = next-door
              [
                set next-door nobody
              ]
            ]
          ]

          ]
          put-patch-to-visited patch-here

        ]

    ]

    set pressure 0
    if breed != corpses [
      set color white
    ]
  ]
  tick
end

;;find-better-next-door
;;finds door with better priory
to-report find-better-next-door
  if [pcolor] of next-door = yellow
  [
    report false
  ]
  let find-door (move-to-door yellow visited-patches)
  ifelse (find-door = false)
  [
     if [pcolor] of next-door = green
      [
       report false
      ]
    set find-door (move-to-door green visited-patches)
    ifelse (find-door = false)
    [
      if [pcolor] of next-door = red
      [
       report false
      ]
      report move-to-door red visited-patches
    ]
    [
       report true
    ]
  ]
  [
     report true
  ]

end

;;put patch to visited
;;if its door put all neighbouring patches of the same color to visited as well
to put-patch-to-visited [patch-to-visited]

  ;;output-print(word self " is on " patch-to-visited " isDoor:" [isDoor] of patch-to-visited)

  if patch-to-visited != prev-patch
  [
    if not member? patch-to-visited visited-patches
    [
      ;;output-print(word patch-to-visited " moved to visited")
      set visited-patches lput patch-to-visited visited-patches
      if [is-door] of patch-to-visited = true
      [
        put-patch-neighbours patch-to-visited
      ]
    ]

  ]

end

;;put neighbouring patches of the same color to visited list
to put-patch-neighbours [patch-to-visited]

 ;; output-print(word self " blacklist patch " patch-to-visited " visited list")
   if not member? patch-to-visited visited-patches
  [
    set visited-patches lput patch-to-visited visited-patches
  ]
      let patch-up patch [pxcor] of patch-to-visited ([pycor] of patch-to-visited + 1)
      if patch-up != nobody and [is-door] of patch-up = true
      [
        if not member? patch-up visited-patches
        [
          put-patch-neighbours patch-up
        ]
      ]
      let patch-down patch ([pxcor] of patch-to-visited) ([pycor] of patch-to-visited - 1)
      if patch-down != nobody and [is-door] of patch-down = true
      [
        if not member? patch-down visited-patches
        [
          put-patch-neighbours patch-down
        ]
      ]
      let patch-left patch ([pxcor] of patch-to-visited - 1) ([pycor] of patch-to-visited)
      if patch-left != nobody and [is-door] of patch-left = true
      [
        if not member? patch-left visited-patches
        [
          put-patch-neighbours patch-left
        ]
      ]
      let patch-right patch ([pxcor] of patch-to-visited + 1) ([pycor] of patch-to-visited)
      if patch-right != nobody and [is-door] of patch-right = true
      [
        if not member? patch-right visited-patches
        [
          put-patch-neighbours patch-right
        ]
      ]
end


;;put patch to prev-door
;;if its door put all neighbouring patches of the same color to prev-door as well
to put-patch-to-prev-door [patch-to-visited]

  ;;output-print(word self " is on " patch-to-visited " isDoor:" [isDoor] of patch-to-visited)

    if not member? patch-to-visited prev-door
    [
      ;;output-print(word patch-to-visited " moved to visited")
      if [is-door] of patch-to-visited = true
      [
        put-patch-neighbours-prev-door patch-to-visited
      ]
    ]



end

;;put neighbouring patches of the same color to prev-door list
to put-patch-neighbours-prev-door [patch-to-visited]

   if not member? patch-to-visited prev-door
  [
    set prev-door lput patch-to-visited prev-door
  ]
      let patch-up patch [pxcor] of patch-to-visited ([pycor] of patch-to-visited + 1)
      if patch-up != nobody and [is-door] of patch-up = true
      [
        if not member? patch-up prev-door
        [
          put-patch-neighbours-prev-door patch-up
        ]
      ]
      let patch-down patch ([pxcor] of patch-to-visited) ([pycor] of patch-to-visited - 1)
      if patch-down != nobody and [is-door] of patch-down = true
      [
        if not member? patch-down prev-door
        [
          put-patch-neighbours-prev-door patch-down
        ]
      ]
      let patch-left patch ([pxcor] of patch-to-visited - 1) ([pycor] of patch-to-visited)
      if patch-left != nobody and [is-door] of patch-left = true
      [
        if not member? patch-left prev-door
        [
          put-patch-neighbours-prev-door patch-left
        ]
      ]
      let patch-right patch ([pxcor] of patch-to-visited + 1) ([pycor] of patch-to-visited)
      if patch-right != nobody and [is-door] of patch-right = true
      [
        if not member? patch-right prev-door
        [
          put-patch-neighbours-prev-door patch-right
        ]
      ]
end


;;make random move
to make-move-random [degree]
  ;;output-print(word self "make random move")
  lt random degree
  rt random degree

  while [[pcolor] of patch-ahead 1 = blue]
  [
    lt random degree
    rt random degree
  ]
  fd 0.05
  set move-steps move-steps + 1
end


;;move-to-door if is in sight
to-report move-to-door [door-color blacklist-patches]

  ;;get nearest patch of door-color
  let patch-to min-one-of patches with [ pcolor = door-color and not member? self blacklist-patches][distance myself]

  ;;output-print(word self " " patch-to " " [pcolor] of patch-to)
  ;;if random patch from nearest is in line of sight, set next door
  ifelse is-in-line-of-sight patch-to ;;((remainder (random 100) 2) + 1)
  [
    make-move patch-to
    ;;make-move-random 5
    ;;output-print(word self " moves to " patch-to " with color " [pcolor] of patch-to)
    set next-door patch-to
    report true
  ]
  ;;check all door neighbours patches if there are is sight
  [
    ifelse is-in-line-of-sight-neighbours patch-to 3
    [
      make-move patch-to
      ;;make-move-random 5
      ;;output-print(word self " moves to " patch-to " with color " [pcolor] of patch-to)
      set next-door patch-to
      report true
    ]
    [
      report false
    ]

  ]

end

;;check if raandom patch from parent-patch is in sight
;;we want something else then nearest patch
to-report is-in-line-of-sight-random [parent-patch random-dist]

 ;; output-print(word self " random " random-dist)
  if parent-patch != nobody
  [

      let patch-up patch [pxcor] of parent-patch ([pycor] of parent-patch + random-dist)
    if patch-up != nobody and [pcolor] of patch-up = [pcolor] of parent-patch and [is-door] of patch-up
      [
        if is-in-line-of-sight patch-up
        [
          set next-door patch-up
          report true
        ]
      ]

      let patch-down patch [pxcor] of parent-patch ([pycor] of parent-patch - random-dist)
      if patch-down != nobody and [pcolor] of patch-down = [pcolor] of parent-patch and [is-door] of patch-down
      [
        if is-in-line-of-sight patch-down
        [
          set next-door patch-down
          report true
        ]
      ]

      let patch-left patch ([pxcor] of parent-patch + random-dist) [pycor] of parent-patch
      if patch-left != nobody and [pcolor] of patch-left = [pcolor] of parent-patch and [is-door] of patch-left
      [
        if is-in-line-of-sight patch-left
        [
          set next-door patch-left
          report true
        ]
      ]

      let patch-right patch ([pxcor] of parent-patch + random-dist) [pycor] of parent-patch
      if patch-right != nobody and [pcolor] of patch-right = [pcolor] of parent-patch and [is-door] of patch-right
      [
        if is-in-line-of-sight patch-right
        [
          set next-door patch-right
          report true
        ]
      ]

  ]
  report false
end

;;check if some neighbouring patch is in sight to the distance
to-report is-in-line-of-sight-neighbours [parent-patch max-dist-of-neighbours]


  if parent-patch != nobody
  [
    ;;output-print(word self "checks neighbours" [pcolor] of parent-patch)
    let curr-dist 1
    while [curr-dist <= max-dist-of-neighbours]
    [
      let patch-up patch [pxcor] of parent-patch ([pycor] of parent-patch + curr-dist)
      if patch-up != nobody and [pcolor] of patch-up = [pcolor] of parent-patch
      [
        if is-in-line-of-sight patch-up
        [
          report true
        ]
      ]

      let patch-down patch [pxcor] of parent-patch ([pycor] of parent-patch - curr-dist)
      if patch-down != nobody and [pcolor] of patch-down = [pcolor] of parent-patch
      [
        if is-in-line-of-sight patch-down
        [
          report true
        ]
      ]

      let patch-left patch ([pxcor] of parent-patch + curr-dist) [pycor] of parent-patch
      if patch-left != nobody and [pcolor] of patch-left = [pcolor] of parent-patch
      [
        if is-in-line-of-sight patch-left
        [
          report true
        ]
      ]

      let patch-right patch ([pxcor] of parent-patch + curr-dist) [pycor] of parent-patch
      if patch-right != nobody and [pcolor] of patch-right = [pcolor] of parent-patch
      [
        if is-in-line-of-sight patch-right
        [
          report true
        ]
      ]
      set curr-dist curr-dist + 1
    ]
  ]
  report false
end

;;check if patch is in sight (no wall between)
to-report is-in-line-of-sight [patch-to]
  if patch-to = nobody [
    report false
  ]
;;output-print(word self " " [pcolor] of patch-to)
  let dist-of-patch (distancexy [pxcor] of patch-to [pycor] of patch-to)
  let dist 1
  let c color
  let last-patch patch-here
  let wall-count 0
  face patch-to
  while [dist <= dist-of-patch]
  [
    let p patch-ahead dist
    ;; if we are looking diagonally across
    ;; a patch it is possible we'll get the
    ;; same patch for distance x and x + 1
    ;; but we don't need to check again.
    if p != last-patch [
      ask p
      [
        ;;if green door we do not want red between too (it is wrong direction of door)
        ifelse [pcolor] of patch-to = green
        [
          if pcolor = blue or pcolor = red
          [
            set wall-count wall-count + 1
            ;;output-print "is in line of sight"
          ]
        ]
        [
          if pcolor = blue
          [
            set wall-count wall-count + 1
            ;;output-print (word "is in line of sight " wall-count)
          ]
        ]
      ]
      set last-patch p
    ]
    set dist dist + 1
  ]

  ifelse wall-count > 0
  [
    report false
  ]
  [
    report true
  ]
end

to make-move [to-patch]
  ;;output-print(word self "make move to " to-patch)
  face to-patch
  let moved true

  lt random 10
  rt random 10
  if not move-ahead [
    set moved try-to-get-round
  ]

  if not moved [
    face to-patch
    push-people-ahead
  ]
  set move-steps move-steps + 1
end

to-report move-ahead
  if not is-wall-ahead and not is-person-ahead [
    fd 0.05
    report true
  ]
  report false
end

to-report try-to-get-round
  let side select-side

  left 45 * side
  if not move-ahead [
    left 45 * side
    report move-ahead
  ]
  report true
end

to-report select-side
  if [pcolor] of patch-left-and-ahead 45 2 = blue [
    report -1
  ]
  if [pcolor] of patch-right-and-ahead 45 2 = blue [
    report 1
  ]

  left 45
  let left-overload count people in-cone 1 90
  right 90
  let right-overload count people in-cone 1 90
  left 45

  ifelse left-overload < right-overload [
    report 1
  ] [
    report -1
  ]
end

to-report is-wall-ahead
  report [pcolor] of patch-ahead 1 = blue
end

to-report is-person-ahead
  report count other people in-cone 1 135 > 0
end

to push-people-ahead
  let people-ahead other people in-cone 1 135

  if count people-ahead > 0 [
    let pressure-to-add (pressure + 1) / count people-ahead
    ask people-ahead [
      set pressure pressure + pressure-to-add
      let clr 255 * (1 - (pressure / max-pressure)) mod 255
      set color (list 255 clr clr)
      if pressure > max-pressure [
        set color black
        set breed corpses
      ]
    ]
  ]
end

;;import map from file (use editor for creating map), inspiration from pacman
to import-from-file
  let file-name ""
  set file-name user-input "Name of file with map"

  let filepath (word "./maps/" file-name ".csv")
  ifelse user-yes-or-no? (word "Load File: " filepath
         "\nThis will clear your current map and replace it with the map loaded."
         "\nAre you sure you want to Load?")
  [
    import-world filepath
    user-message "Map imported."
  ]
  [ user-message "Import Canceled. File not found." ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report find-door-in-room [patch-room]

  ifelse patch-room != nobody
  [
    ifelse not member? patch-room visited-door-patches
    [
      set visited-door-patches lput patch-room visited-door-patches
      ifelse [pcolor] of patch-room = blue
      [
        report false
      ]
      [
        ifelse [is-door] of patch-room = true
        [
          set door-patches lput patch-room door-patches
          report true
        ]
        [

          let patch-up patch [pxcor] of patch-room ([pycor] of patch-room + 1)
          let result-up find-door-in-room patch-up
          let patch-down patch [pxcor] of patch-room ([pycor] of patch-room - 1)
          let result-down find-door-in-room patch-down
          let patch-left patch ([pxcor] of patch-room - 1) [pycor] of patch-room
          let result-left find-door-in-room patch-left
          let patch-right patch ([pxcor] of patch-room + 1) [pycor] of patch-room
          let result-right find-door-in-room patch-right
          report result-up or result-down or result-left or result-down
        ]
      ]
    ]
    [
      report false
    ]
  ]
  [
    report false
  ]
end

to-report sort-by-color [patch1 patch2]
  let pcolor1 [pcolor] of patch1
  let pcolor2 [pcolor] of patch2
  ifelse pcolor1 = pcolor2
  [
    report (distance patch1) < (distance patch2)
  ]
  [
    report pcolor1 > pcolor2
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
286
12
1074
801
-1
-1
12.0
1
10
1
1
1
0
0
0
1
-32
32
-32
32
0
0
1
ticks
30.0

BUTTON
34
47
103
80
Import
import-from-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
23
160
195
193
people-count
people-count
0
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
140
46
204
79
Setup
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
35
92
118
125
Go Step
go2
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
1182
68
1784
494
11

MONITOR
13
320
70
365
Freed
freed
17
1
11

BUTTON
140
92
241
125
Go forever
go2
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
23
203
195
236
max-pressure
max-pressure
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
87
320
144
365
Dead
count corpses
17
1
11

MONITOR
166
318
262
363
Timer [ticks]
ticks
17
1
11

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
NetLogo 6.0.1
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

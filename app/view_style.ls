Colour = require \color

/*  This class will contain all the various styles that can be used
 *  for nodes.
 *  Please do expand it!
 *
 *  **** Node Styles ****
 *  standard
 *  destination
 *  dev
 *  selected
 *
 *  ** Audio **
 *  audio-pause
 *  audio-reset
 *  delay
 *  delay-gain
 *  gain
 *  mixer
 *  oscillator
 *
 *  ** Numerical **
 *  add-node
 *  constant
 *  subtracter
 *  multiplier
 *  inverter
 *  slider
 *    slider
 *    slider-path
 *    slider-track
 *  toggle
 *    toggle
 *    toggle-down
 *    toggle-up
 *  xy-slider
 *    x-slider
 *    xy-slider-bed
 *    xy-slider-centre
 *    xy-slider-line-active
 *    xy-slider-line-idle
 *    y-slider
 *
 *  **** Ports ****
 *  port
 *
 *  ** Numerical **
 *  numerical-busy
 *  numerical-free
 *
 *  ** Audio **
 *  audio-busy
 *  audio-free
 *
 *  ** Standard **
 *  standard-busy
 *  standard-free
 *
 *  **** Wires ****
 *  wire
 *  wire-active
 *  wire-idle
 *  wire-selected
 *  wire-tuning-complete
 *
 *  **** Pointers ****
 *  pan-pointer
 *  zoom-pointer
 *
 *  **** Catch-All ****
 *  other-type
 *
 *  **** Methods ****
 *  view-style-for-pointers(pt-info: PointInfo): paper.Shape
 *    returns the appropriate styling given a type of point.
 *
 *  view-styles-for-type(type : String) : (Style, Style)
 *    returns the standard and busy styles for a given data type
 *
 *  **** Other ****
 *  slider-colours
 *  label
 *  black-label
 *  white-label
 */

LINE_COLOUR = Colour.black

/** Nodes **/

export standard =
  stroke-color: LINE_COLOUR,
  stroke-width: 5,
  fill-color: Colour.white

export destination = standard with
  fill-color: Colour.black

export dev = standard with
  stroke-color: Colour.blue

export selected = standard with
  stroke-color: Colour.elsa-blue

/** Audio **/
export audio-pause = standard with
  fill-color: Colour.cinnamon-orange

export audio-reset = standard with
  fill-color: Colour.cinnamon-orange

export delay = standard with
  fill-color: Colour.butterfly-blue

export delay-gain = standard with
  fill-color: Colour.white

export gain = standard with
  fill-color: Colour.white

export mixer = standard with
  fill-color: Colour.bee-yellow

export oscillator = standard with
  fill-color: Colour.purpleMonster

/** Numerical **/
export add-node = standard with
  fill-color: Colour.midnight-blue

export constant = standard with
  fill-color: Colour.welsh-grey
  
export inverter = standard with
  fill-color: Colour.midnight-blue

export mult-node = standard with
  fill-color: Colour.midnight-blue

export slider = standard with
  fill-color: Colour.love-red

export slider-path = standard with
  fill-color: Colour.love-red

export slider-track = standard with
  stroke-width: 10,
  fill-color: Colour.black

export sub-node = standard with
  fill-color: Colour.midnight-blue

export toggle = standard with
  fill-color: Colour.pink-cupcake

export toggle-down = standard with
  fill-color: Colour.oz-green
  
export toggle-up = standard with
  fill-color: Colour.fire-engine-red

export toggle-up = standard with
  fill-color: Colour.fire-engine-red

export x-slider = standard with
  fill-color: Colour.alpha-black

export xy-slider-bed = standard with
  fill-color: Colour.alpha-black

export xy-slider-centre = standard with
  fill-color: Colour.oz-green

export xy-slider-line-idle = standard

export xy-slider-line-active = standard with
  stroke-color: Colour.alien-green

export y-slider = standard with
  fill-color: Colour.alpha-white

/** Ports **/

export port = standard with
  stroke-width: 3

/** Numerical ports **/

export numerical-busy = port with
  stroke-color: Colour.green,
  fill-color: Colour.yellow

export numerical-free = port with
  stroke-color: LINE_COLOUR,
  fill-color: Colour.yellow

/** Audio ports **/

export audio-busy = port with
  stroke-color: Colour.green,
  fill-color: Colour.blue

export audio-free = port with
  stroke-color: LINE_COLOUR,
  fill-color: Colour.blue

/** Standard ports **/

export standard-busy  = port with
  stroke-color: LINE_COLOUR,
  fill-color: Colour.love-red

export standard-free = port with
  stroke-color: LINE_COLOUR,
  fill-color: Colour.red

/** Wires **/

export wire =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  stroke-cap: \round

export wire-active = wire with
  stroke-color: Colour.green

export wire-idle = wire with
  stroke-color: Colour.white

export wire-selected = wire with
  stroke-color: Colour.red

export wire-tuning-complete = wire with
  stroke-color: Colour.love-red

/** Pointers **/

export zoom-pointer =
  fill-color: Colour.dark-blue

export pan-pointer =
  fill-color: Colour.dark-blue

/** Catch all **/

export other-type = standard with
  stroke-width: 3,
  fill-color: Colour.black

export view-style-for-pointers = (pt-info) ->
  ui-unit = 10
  switch pt-info.type
  | \finger =>
    pt = new paper.Shape.Circle do
      center: pt-info.pt,
      radius: 10
    if pt-info.z < 0
      pt.style =
        fill-color: new paper.Color 1, 0, 0
    else if pt-info.z < ui-unit
      pt.style =
        fill-color: new paper.Color 1, pt-info.z / ui-unit, 0
    else
      pt.style =
        fill-color: new paper.Color 1, 1, 0
    pt
  | \hand =>
    pt = new paper.Shape.Circle do
      center: pt-info.pt,
      radius: 20
    if pt-info.z < 1
      pt.style =
        fill-color: new paper.Color 0, 0.2, 0
    else if pt-info.z < ui-unit + 1
      pt.style =
        fill-color: new paper.Color 0, 0.2 + 0.8 * (pt-info.z - 1) / ui-unit, 0
    else
      pt.style =
        fill-colour: new paper.Color 0, 1, 0
    pt
  | \zoom =>
    pt = new paper.Shape.Circle do
      center: pt-info.pt,
      radius: 20
    pt.style = zoom-pointer
    pt
  | \pan =>
    pt = new paper.Shape.Circle do
      center: pt-info.pt,
      radius: 20
    pt.style = pan-pointer
    pt
  | \drag =>
    pt = new paper.Shape.Circle do
      center: pt-info.pt,
      radius: 10
    pt.style =
      fill-color: Colour.light-grey
    pt

export view-styles-for-type = (type) ->
  switch type
  | \Audio     => [audio-free, audio-busy]
  | \Numerical => [numerical-free, numerical-busy]
  | \Standard  => [standard-busy, standard-free]
  | otherwise  => [other-type, other-type]

/** Other **/

export slider-colours = 
  [ 
    Colour.scarlet,
    Colour.construction-cone-orange, 
    Colour.rubber-ducky-yellow, 
    Colour.alien-green, 
    Colour.blue-ribbon, 
    Colour.indigo, 
    Colour.lovely-purple, 
    Colour.blossom-pink
  ]

export label =
  fill-color: Colour.black

export black-label = Colour.alpha-black
export white-label = Colour.alpha-white

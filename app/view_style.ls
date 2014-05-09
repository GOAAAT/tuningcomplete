Colour = require \color

/*  This class will contain all the various styles that can be used
 *  for nodes.
 *  Please do expand it!
 *
 *  **Node Styles**
 *
 *  Maths Nodes
 *  Oscillator Nodes
 *  Standard Nodes
 *
 *  **Inport and outport styles**
 *  Audio
 *  Numerical
 *  Standard
 *
 *  **Wire Styles**
 *  Standard Idle
 *
 *  **Pointer Styles**
 *  Finger pointers
 *   -active
 *   -close
 *   -other
 *  Hand Pointers
 *  Zoom Pointers
 *  Pan Pointers
 *
 *  Methods:
 *  view-style-for-pointers(pt-info: PointInfo): paper.Shape
 *    returns the appropriate styling given a type of point.
 *
 *  view-styles-for-type(type : String) : (Style, Style)
 *    returns the standard and busy styles for a given data type
 */

LINE_COLOUR = Colour.black

/** Nodes **/

export standard =
  stroke-color: LINE_COLOUR,
  stroke-width: 5,
  fill-color: Colour.white

export nand-node =
  fill-color: Colour.burgundy

export constant = standard with
  fill-color: Colour.welsh-grey

export delay-gain = standard with
  fill-color: Colour.butterfly-blue

export destination = standard with
  fill-color: Colour.black

export gain = standard with
  fill-color: Colour.elsa-blue

export maths = standard with
  fill-color: Colour.blue

export mixer = standard with
  fill-color: Colour.bee-yellow

export oscillator = standard with
  fill-color: Colour.purpleMonster

export slider = standard with
  fill-color: Colour.love-red

export slider-path = standard with
  fill-color: Colour.love-red

export slider-track = standard with
  stroke-width: 10,
  fill-color: Colour.black

export toggle = standard with
  fill-color: Colour.pink-cupcake

export toggle-down = standard with
  fill-color: Colour.oz-green

export toggle-up = standard with
  fill-color: Colour.fire-engine-red

export x-slider = standard with
  fill-color: Colour.alpha-black

export y-slider = standard with
  fill-color: Colour.alpha-white

export xy-slider-bed = standard with
  fill-color: Colour.alpha-black

export xy-slider-centre = standard with
  fill-color: Colour.oz-green

export xy-slider-line-idle = standard

export xy-slider-line-active = standard with
  stroke-color: Colour.alien-green

export selected = standard with
  stroke-color: Colour.elsa-blue

/** Numerical ports **/

export port = standard with
  stroke-width: 3

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

/** Standard Inports **/

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

export active-pointer =
  fill-color: \red

export close-pointer =
  fill-color: \orange

export close-hand-pointer =
  fill-color: \darkGreen

export finger-pointer =
  fill-color: \yellow

export hand-pointer =
  fill-color: \green

export pan-pointer =
  fill-color: \blue

export zoom-pointer =
  fill-color: \blue

/** Catch all **/

export other-type = standard with
  stroke-width: 3,
  fill-color: Colour.black

export view-style-for-pointers = (pt-info) ->
  switch pt-info.type
  | \finger =>
    pt = new paper.Shape.Circle do
      center: pt-info.pt,
      radius: 10
    if pt-info.z < 0
      pt.style = active-pointer
    else if pt-info.z < 4
      pt.style = close-pointer
    else pt.style = finger-pointer
    pt
  | \hand =>
    pt = new paper.Shape.Circle do
      center: pt-info.pt,
      radius: 20
    if pt-info.z < 1
      pt.style = close-hand-pointer
    else
      pt.style = hand-pointer
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

export view-styles-for-type = (type) ->
  switch type
  | \Audio     => [audio-free, audio-busy]
  | \Numerical => [numerical-free, numerical-busy]
  | \Standard  => [standard-busy, standard-free]
  | otherwise  => [other-type, other-type]

export slider-colours = [Colour.scarlet, Colour.construction-cone-orange, Colour.rubber-ducky-yellow, Colour.alien-green, Colour.blue-ribbon, Colour.indigo, Colour.lovely-purple, Colour.blossom-pink]

export label =
  fill-color: Colour.black
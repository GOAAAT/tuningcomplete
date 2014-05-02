Colour = require \color

/*  This class will contain all the various styles that can be used
 *  for nodes.
 *  Please do expand it!
 *
 *  **Node Styles**
 *
 *  Maths Nodes
 *  Instrument Nodes
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

export maths =
  stroke-color: LINE_COLOUR,
  stroke-width: 5,
  fill-color: Colour.blue

export instrument =
  stroke-color: LINE_COLOUR,
  stroke-width: 5,
  fill-color: Colour.bee-yellow

export oscillator =
  stroke-color: LINE_COLOUR,
  stroke-width: 5,
  fill-color: Colour.purpleMonster

export standard =
  stroke-color: LINE_COLOUR,
  stroke-width: 5,
  fill-color: Colour.cyan

export node-selected =
  stroke-color: Colour.blue,
  stroke-width: 5,
  fill-color: Colour.cyan

/** Numerical ports **/

export numerical-busy =
  stroke-color: Colour.green,
  stroke-width: 3,
  fill-color: Colour.yellow

export numerical-free =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.yellow

/** Audio ports **/

export audio-busy =
  stroke-color: Colour.green,
  stroke-width: 3,
  fill-color: Colour.blue

export audio-free =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.blue

/** Standard Inports **/

export standard-busy  =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.love-red

export standard-free =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.red

/** Wires **/

export wire-idle =
  stroke-color: Colour.white,
  stroke-width: 3,
  stroke-cap: \round

export wire-active =
  stroke-color: Colour.green,
  stroke-width: 3,
  stroke-cap: \round

export wire-selected =
  stroke-color: Colour.red,
  stroke-width: 3,
  stroke-cap: \round

/** Pointers **/

export finger-pointer =
  fill-color: \red

export hand-pointer =
  fill-color: \green

export zoom-pointer =
  fill-color: \blue

export pan-pointer =
  fill-color: \blue

/** Catch all **/

export other-type =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.black

export view-style-for-pointers = (pt-info) ->
  switch pt-info.type
  | \finger =>
    pt = new paper.Shape.Circle do
      center: pt-info.pt,
      radius: 10
    pt.style = finger-pointer
    pt
  | \hand =>
    pt = new paper.Shape.Circle do
      center: pt-info.pt,
      radius: 20
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

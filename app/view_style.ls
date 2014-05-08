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

export destination =
  stroke-color: LINE_COLOUR,
  stroke-width: 5,
  fill-color: Colour.black

export mixer = instrument

export standard =
  stroke-color: LINE_COLOUR,
  stroke-width: 5,
  fill-color: Colour.cyan

export selected =
  stroke-color: Colour.blue

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

export zoom-pointer =
  fill-color: Colour.dark-blue

export pan-pointer =
  fill-color: Colour.dark-blue

/** Catch all **/

export other-type =
  stroke-color: LINE_COLOUR,
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

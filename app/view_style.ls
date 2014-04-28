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

/** Numerical Inports **/

export numerical-busy =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.love-red

export numerical-free =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.yellow
  
/** Audio Inports **/

export audio-busy =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.love-red
  
export audio-free =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.green

/** Standard Inports **/

export standard-busy  = 
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.love-red
    
export standard-free = 
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.red
  
/** Outports **/

export numerical-out =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.white

export audio-out =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.white

export standard-out = 
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.white

/** Wires **/

export wire-idle =
  stroke-color: Colour.white,
  stroke-width: 3,
  stroke-cap: "round"

/** Catch all **/

export other-type =
  stroke-color: LINE_COLOUR,
  stroke-width: 3,
  fill-color: Colour.black
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

/** Nodes **/

export maths =
  stroke-color: Colour.black,
  stroke-width: 5,
  fill-color: Colour.blue
  
export instrument =
  stroke-color: Colour.black,
  stroke-width: 5,
  fill-color: Colour.bee-yellow

export oscillator = 
  stroke-color: Colour.black,
  stroke-width: 5,
  fill-color: Colour.purpleMonster
  
export standard =
  stroke-color: Colour.black,
  stroke-width: 5,
  fill-color: Colour.cyan

/** Numerical Inports **/

export numerical-busy =
  stroke-color: Colour.black,
  stroke-width: 3,
  fill-color: Colour.love-red

export numerical-clear =
  stroke-color: Colour.black,
  stroke-width: 3,
  fill-color: Colour.dark-blue
  
/** Audio Inports **/

export audio-busy =
  stroke-color: Colour.black,
  stroke-width: 3,
  fill-color: Colour.love-red
  
export audio-clear =
  stroke-color: Colour.black,
  stroke-width: 3,
  fill-color: Colour.purple-monster

/** Standard Inports **/

export standard-busy  = 
  stroke-color: Colour.black,
  stroke-width: 3,
  fill-color: Colour.green
    
export standard-free = 
  stroke-color: Colour.black,
  stroke-width: 3,
  fill-color: Colour.red
  
/** Outports **/
    
export standard-out = 
  stroke-color: Colour.black,
  stroke-width: 3,
  fill-color: Colour.white
  
/** Wires **/

export wire-idle =
  stroke-color: Colour.black,
  stroke-width: 3
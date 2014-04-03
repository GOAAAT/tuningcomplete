Colour = require \color

/*  This class will contain all the various styles that can be used 
 *  for nodes.
 *  Please do expand it!
 *
 *  Maths Nodes
 *  Instrument Nodes
 *  Oscillator Nodes
 *  Standard Nodes
 *
 *  Inport and outport styles
 *
 */

/*
 *	Maths Nodes
 */
 
export maths =
  strokeColor: Colour.black,
  strokeWidth: 5,
  fillColor: Colour.blue
  
export instrument =
  strokeColor: Colour.black,
  strokeWidth: 5,
  fillColor: Colour.beeYellow

export oscillator = 
  strokeColor: Colour.black,
  strokeWidth: 5,
  fillColor: Colour.purpleMonster
  
export standard =
  strokeColor: Colour.black,
  strokeWidth: 5,
  fillColor: Colour.cyan

export inport-busy  = 
    strokeColor: Colour.black,
    strokeWidth: 3,
    fillColor: Colour.green
    
export inport-clear = 
    strokeColor: Colour.black,
    strokeWidth: 3,
    fillColor: Colour.red
    
export outport = 
    strokeColor: Colour.black,
    strokeWidth: 3,
    fillColor: Colour.white

export wire-idle =
  strokeColor: Colour.black,
  strokeWidth: 3
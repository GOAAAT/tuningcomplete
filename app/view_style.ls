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
 
maths =
  strokeColor: Colour.black,
  strokeWidth: 5,
  fillColor: Colour.blue
  
instrument =
  strokeColor: Colour.black,
  strokeWidth: 5,
  fillColor: Colour.beeYellow

oscillator = 
  strokeColor: Colour.black,
  strokeWidth: 5,
  fillColor: Colour.purpleMonster
  
standard =
  strokeColor: Colour.black,
  strokeWidth: 5,
  fillColor: Colour.cyan

/* make-port (col : Colour)
 *
 * Makes a port of a given colour
 *
 */

_make-port: (col) ->
  res = 
    strokeColor: Colour.black,
    strokeWidth: 3,
    fillColor: col

inport_busy  = _make-port Colour.green 
inport_clear = _make-port Colour.red
outport      = _make-port Colour.white

wire_idle =
  strokeColor: Colour.black,
  strokeWidth: 3

export maths
export instrument
export oscillator
export standard

export wire_idle

export inport_busy
export inport_clear
export outport
Node = require \node
Input = require \input
VS = require \view_style

module.exports = class NumericalNode extends Node

  /* NumericalNode (pos : paper.Point, noinputs : int) : void
   * Creates a numerical node at pos
   */
   
  (pos, noinputs) ->
  
    super "Numerical", 0, noinputs, pos
    
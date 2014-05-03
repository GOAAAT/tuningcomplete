Node = require \node
Input = require \input
VS = require \view_style

module.exports = class NumericalNode extends Node

  @desc = "produces a numerical output"

  /* NumericalNode (pos : paper.Point, noinputs : int) : void
   * Creates a numerical node at pos
   */
   
  (pos, noinputs) ->
  
    super "Numerical", 0, noinputs, pos
    
    @value = 0
    
    @active-view.set-node-style VS.maths
    
  /* send () : void
   * Sends its value to all its children
   */ 
   
  send: !-> @send-list |> map (.receive @value)
  
  /* receive () : void
   * Receives the value
   */
   
  receive: (@value) !-> console.log @value
Node = require \node
Input = require \input
VS = require \view_style
{map} = prelude

module.exports = class AudioNode extends Node

  @desc = "produces an audio output"

  /* AudioNode (pos : paper.Point) : void
   * Creates an audio node at pos
   */
   
  (pos) ->
  
    super "Numerical", 1, 1, pos
    
    @active-view.set-node-style VS.instrument
    
    @source = new AudioNode
    
  /* register-output (wire) : void
   * connects the node to other nodes
   */
   
  register-output: (wire) !->
    @source.connect wire.dest
    super wire
    
  /* rem-output (node) : void
   * removes the connection
   */
   
  rem-output: (node) !->
    super node
    @source.disconnect!
    @send-list |> map (@source.connect)
Node = require \node
Input = require \input
VS = require \view_style

module.exports = class AudioNode extends Node

  @desc = "produces an audio output"

  /* AudioNode (pos : paper.Point, noinputs : int) : void
   * Creates an audio node at pos with number of audio inputs noinputs
   */
   
  (pos, noinputs) ->
  
    super "Numerical", noinputs, 0, pos
    
    @value = 0
    
    @active-view.set-node-style VS.instrument
    
    @source
    
  /* register-output (wire) : void
   * connects the node to other nodes
   */
   
  register-output: (wire) !->
    @send-list.push wire.dest
    @source.connect wire.dest
    
  /* rem-output (node) : void
   * removes the connection
   */
   
  rem-output: (node) !->
    
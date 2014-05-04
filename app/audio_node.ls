Node = require \node
Input = require \input
VS = require \view_style
{map} = prelude

module.exports = class Audio extends Node

  @desc = "produces an audio output"

  /* AudioNode (pos : paper.Point) : void
   * Creates an audio node at pos
   */

  (pos, audioin, numin) ->

    super "Audio", audioin, numin, pos

    @active-view.set-node-style VS.instrument

    @audio-node = new AudioNode

  /* register-output (wire) : void
   * connects the node to other nodes
   */

  register-output: (wire) !->
    @audio-node.connect wire.dest
    super wire

  /* rem-output (node) : void
   * removes the connection
   */

  rem-output: (node) !->
    super node
    @audio-node.disconnect!
    @send-list |> map @audio-node~connect

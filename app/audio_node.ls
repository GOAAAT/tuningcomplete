Node = require \node
Input = require \input
VS = require \view_style
{map} = prelude

module.exports = class Audio extends Node
  /** Audio
   *  audioin : Int
   *  numin   : Int
   *  pos     : paper.Point
   *
   * Creates an audio node at `pos` with `audioin` audio inputs and
   * `numin` numeric inputs.
   */
  (audioin, numin, pos) ->
    super \Audio audioin, numin, pos

    @active-view.set-node-style VS.instrument

  /** register-output : void
   *  wire : Wire
   *
   * Notifies this node that they should start sending information down
   * this wire.
   */
  register-output: (wire) !->
    @audio-node.connect wire.dest
    super wire

  /** rem-output : void
   *  wire : Wire
   *
   * Notifies this node that they should no longer send information down this
   * wire.
   */
  rem-output: (wire) !->
    super wire
    @audio-node.disconnect!
    @send-list |> map @audio-node~connect

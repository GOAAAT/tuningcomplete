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

  /** (override) register-output : void
   *  wire : Wire
   *
   * Notifies this node that they should start sending information down
   * this wire.
   */
  register-output: (wire) !->
    @_connect wire
    super wire

  /** (override) rem-output : void
   *  wire : Wire
   *
   * Notifies this node that they should no longer send information down this
   * wire.
   */
  rem-output: (wire) !->
    super wire
    @_disconnect!
    @send-list |> map @audio-node~connect

  /** (protected abstract) _connect : void
   *  wire : Wire
   *
   * Attempt to connect the audio node to the given wire. Return a boolean
   * flag to indicate success.
   */
  _connect: (wire) !->

  /** (protected abstract) _disconnect : void
   *
   * Disconnect the audio node from everything.
   */
  _disconnect : !->

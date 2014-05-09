Node = require \node
Input = require \input
VS = require \view_style
{map} = prelude

module.exports = class Numerical extends Node
  /** Numerical
   *  audioin : Int
   *  numin   : Int
   *  pos     : paper.Point
   *
   * Creates a numerical node at `pos` with `audioin` audio inputs and `numin`
   * numerical inputs.
   */
  (audioin, numin, pos) ->
    super \Numerical audioin, numin, pos

    @value = 0
    @active-view.set-node-style VS.maths
    @active-view.set-label "№", \40pt

  /** send : void
   *
   * Sends its value to all its children.
   */
  send: !-> @send-list |> map (wire) ~> wire.input.receive @value

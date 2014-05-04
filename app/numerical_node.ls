Node = require \node
Input = require \input
VS = require \view_style
{map} = prelude

module.exports = class Numerical extends Node

  @desc = "produces a numerical output"

  /* NumericalNode (pos : paper.Point) : void
   * Creates a numerical node at pos
   */

  (pos, audioin, numin) ->

    super "Numerical", audioin, numin, pos

    @value = 0

    @active-view.set-node-style VS.maths

  /* send () : void
   * Sends its value to all its children
   */

  send: !-> @send-list |> map (.receive @value)

  /* receive () : void
   * Receives the value
   */

  receive: (@value) !-> @send!

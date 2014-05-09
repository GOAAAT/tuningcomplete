NumericalNode = require \numerical_node
VS = require \view_style
{min, max} = prelude

module.exports = class Constant extends NumericalNode
  @desc = "Get constant value from user"

  /* Constant (pos) : void
   * Construct a new Constant node
   */

  (pos) ->
    super 0, 0, pos
    @active-view.set-node-style VS.constant

  /* add-to-window (win, cb) : void
   * add the node to the window
   */
  add-to-window: (win, cb) !->
    @set-value prompt "Enter a value"
    @active-view.set-label @value, \32pt, false
    super win, cb

  /* set-value (val) : void
   * Set the value then send it
   */
  set-value: (+@value) !->
    @value = min 1, (max @value, 0)
    @send!

  /* OW/ register-output (wire) : void
  *  Adds the power to send on the value
  */
  register-output: (wire) !->
    super wire
    @send!

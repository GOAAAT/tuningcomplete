NumericalNode = require \numerical_node
VS = require \view_style
{min, max} = prelude

module.exports = class SubNode extends NumericalNode
  @desc = "Performs subtraction logic on two inputs"
  /** SubNode
   */
  (pos) ->
    super 0 2 pos
    @active-view.set-node-style VS.sub-node
    @active-view.set-label "MINUS", \40pt
    @active-view.label.fill-color = VS.white-label

    @val1 = 0
    @val2 = 0

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   *
   * Receive the pitch value from the input.
   */
  receive-for-ref: (ref, value) !->
    if ref == 0 then @val1 = value else @val2 = value
    @value = @val1 - @val2
    @value = min 1, (max 0, @value)
    @send!

  register-output: (wire) !->
    super wire
    @send!

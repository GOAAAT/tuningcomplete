NumericalNode = require \numerical_node
VS = require \view_style

module.exports = class AddNode extends NumericalNode
  @desc = "Performs Add logic on two inputs"
  /** AddNode
   */
  (pos) ->
    super 0 2 pos
    @active-view.set-node-style VS.add-node
    @val1 = 0
    @val2 = 0

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   *
   * Receive the pitch value from the input.
   */
  receive-for-ref: (ref, value) !->
    if ref == 0 then @val1 = value
    else @val2 = value
    @value = @val1 + @val2
    if @value < 0 then @value = 0
    else if @value > 1 then @value = 1
    @send!

  register-output: (wire) !->
    super wire
    @send!

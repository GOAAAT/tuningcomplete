NumericalNode = require \numerical_node
VS = require \view_style

module.exports = class NandNode extends NumericalNode
  @desc = "Performs Nand logic on two inputs"
  /** NandNode
   */
  (pos) ->
    super 0 2 pos
    @active-view.set-node-style VS.nand-node
    @val1 = 0
    @val2 = 0

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   *
   * Receive the pitch value from the input.
   */
  receive-for-ref: (ref, value) !->
    if ref == 0 then val1 = value
    else val2 = value
    if (@val1 != 0 && @val2 != 0)
      @value = 0
    else value = 1
    send!

  register-output: (wire) !->
    super wire
    @send!

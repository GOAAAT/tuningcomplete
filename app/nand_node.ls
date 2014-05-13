NumericalNode = require \numerical_node
VS = require \view_style

module.exports = class NandNode extends NumericalNode
  @desc = "Performs Nand logic on two inputs"
  /** NandNode
   */
  (pos) ->
    super 0 2 pos
    @active-view.set-node-style VS.dev
    @active-view.set-label "☠", \40pt
    @val1 = 0
    @val2 = 0
    @value = 1

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   *
   *  Receive the numerical value from the input.
   */
  receive-for-ref: (ref, value) !->
    if ref == 0 then @val1 = value
    else if ref == 1 then @val2 = value
    if (@val1 != 0 && @val2 != 0)
      @value = 0
    else value = 1
    @send!

  register-output: (wire) !->
    super wire
    @send!

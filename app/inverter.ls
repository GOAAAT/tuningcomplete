NumericalNode = require \numerical_node
VS = require \view_style

module.exports = class InverterNode extends NumericalNode
  @desc = "Inverts a [0..1] signal"
  /*  Inverter (pos) : void
   *  constructor creates an inverter node at pos
   */
  (pos) ->
    super 0 1 pos
    @active-view.set-node-style VS.inverter
    @active-view.set-label "¬", \40pt
    @active-view.label.fill-color = VS.white-label

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   *
   *  Receive an input in [0..1] and output its invertion
   */
  receive-for-ref: (ref, value) !->
    @value = 1 - value
    @send!
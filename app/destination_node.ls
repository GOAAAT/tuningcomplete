FanIn = require \fanin_node
VS    = require \view_style

module.exports = class DestinationNode extends FanIn
  /** DestinationNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * A sink node that connects the network associated with the given
   * audio context `actx` to the computers audio out. The node view
   * will be positioned at `pos`.
   */
  (pos, @actx) ->
    super 0 pos, @actx.destination

    @active-view.set-node-style VS.destination
    @active-view.set-label "►", \40pt
    @active-view.label.fill-color = VS.white-label

  /** (override) has-output : Boolean
   *
   * DestinationNodes are roots of the network, so cannot output to
   * anything else.
   */
  has-output: -> false

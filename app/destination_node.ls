Audio = require \audio_node
VS    = require \view_style
{empty, filter, each} = prelude

module.exports = class DestinationNode extends Audio
  /** DestinationNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * A sink node that connects the network associated with the given
   * audio context `actx` to the computers audio out. The node view
   * will be positioned at `pos`.
   */
  (pos, @actx) ->
    super 1 0 pos
    @inputs.0.audio-node = @actx.destination

    @active-view.set-node-style VS.destination
    @active-view.set-label "►", \40pt
    @active-view.label.fill-color = VS.white-label

    @input = new FanInProxy @inputs.0

  /** (override) has-output : Boolean
   *
   * DestinationNodes are roots of the network, so cannot output to
   * anything else.
   */
  has-output: -> false

  /** (override) find-input : Input
   *  nodetype : String
   */
  find-input: (nodetype) ->
    switch nodetype
    | \Audio    => @input
    | otherwise => undefined

  /** (override) _move-input-wires : Input
   *  pt : paper.Point
   */
  _move-input-wires: (pt) ->
    @input.sources |> each (source) ->
      source?active-view.wire-end!?add pt
        |> source?active-view.set-end

class FanInProxy
  /** FanInProxy
   *  input : Input
   *
   * Allows an input to accept multiple sources.
   */
  (@input) ->
    @sources = []
    @audio-node = @input.audio-node

  /** view : paper.Item
   *
   * Returns the proxied input's view.
   */
  view: -> @input.view!

  /** register-input : void
   *  wire : Wire
   *
   * Informs the proxied port that it is busy.
   */
  register-input: (wire) ->
    @input.register-input wire
    @sources.push wire

  /** remove-input : void
   *  wire : Wire
   *
   * Removes a specific source, and notifies the proxied input if it is no
   * longer busy.
   */
  remove-input: (wire) !->
    @sources = filter (!=wire), @sources
    @input.remove-input! if empty @sources

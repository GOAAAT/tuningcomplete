Audio = require \audio_node
{empty, filter, each} = prelude

module.exports = class FanInNode extends Audio
  /** FanInNode
   *  pos : paper.Point
   *  numerical : Int
   *
   * FanInNode is a special case audio node that only has one audio input.
   * Because it is not ambiguous, multiple audio sources can connect to it.
   */
  (numerical, pos, audio-node) ->
    super 1, numerical, pos
    @inputs.0.audio-node = audio-node
    @input = new FanInProxy @inputs.0

  /** (override) find-input : Input
   *  nodetype : String
   */
  find-input: (nodetype) ->
    switch nodetype
    | \Audio    => @input
    | otherwise => super nodetype

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

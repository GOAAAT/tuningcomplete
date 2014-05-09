Audio = require \audio_node
VS = require \view_style

module.exports = class DelayNode extends Audio
  @desc = "Alters the delay of a given node from [0..5]s"
  /** DelayNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * A node that alters the delay of its audio input by the value
   * of its numerical input.
   */
  (pos, actx) ->
    super 1 1 pos
    @active-view.set-node-style VS.delay
    @active-view.set-label "D", \40pt, false

    @max-delay = 5
    @delay-node = actx.create-delay @max-delay
    @inputs.0.audio-node = @delay-node

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   */
  receive-for-ref: (ref, value) !->
    console.log \DELAY value
    @delay-node.delay-time.value = @max-delay*value

  /** (override protected) _connect : void
   *  input : Input
   *
   * Connect this delay node as the source for the given input.
   */
  _connect: (input) !->
    @delay-node.connect input.audio-node

  /** (override protected) _disconnect : void
   *
   * Disconnect this node from all of its receivers.
   */
  _disconnect: !->
    @delay-node.disconnect!

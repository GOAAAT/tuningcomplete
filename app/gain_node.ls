Audio = require \audio_node
VS = require \view_style

module.exports = class GainNode extends Audio
  @desc = "Alters the gain of a given node"
  /** GainNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * A node that alters the gain (volume) of its audio input by the value
   * of its numerical input.
   */
  (pos, actx) ->
    super 1 1 pos
    @active-view.set-node-style VS.gain

    @gain-node = actx.create-gain!
    @inputs.0.audio-node = @gain-node

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   */
  receive-for-ref: (ref, value) !->
    @gain-node.gain.value = 4*value*value

  /** (override protected) _connect : void
   *  input : Input
   *
   * Connect this gain node as the source for the given input.
   */
  _connect: (input) !->
    @gain-node.connect input.audio-node

  /** (override protected) _disconnect : void
   *
   * Disconnect this node from all of its receivers.
   */
  _disconnect: !->
    @gain-node.disconnect!

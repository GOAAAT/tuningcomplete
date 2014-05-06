Audio = require \audio_node
VS = require \view_style

module.exports = class MixerNode extends Audio
  @desc = "Changes the ratio between two audio sources"
  /** MixerNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   */
  (pos, actx) ->
    super 2 1 pos
    @active-view.set-node-style VS.standard

    @gain-left = actx.create-gain!
    @gain-right = actx.create-gain!
    /* Initially mute the right input */
    @gain-right.gain.value = 0

    @inputs.0.audio-node = @gain-one
    @inputs.1.audio-node = @gain-two

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   */
  receive-for-ref: (ref, value) !->
    @gain-left.gain.value = Math.cos(value * 0.5*Math.PI)
    @gain-right.gain.value = Math.cos((1.0 - value) * 0.5*Math.PI)

  /** (override protected) _connect : void
   *  input : Input
   *
   * Connect this gain node as the source for the given input.
   */
  _connect: (input) !->
    @gain-left.connect input.audio-node
    @gain-right.connect input.audio-node

  /** (override protected) _disconnect : void
   *
   * Disconnect this node from all of its receivers.
   */
  _disconnect: !->
    @gain-left.disconnect!
    @gain-right.disconnect!
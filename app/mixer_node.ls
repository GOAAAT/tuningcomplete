Audio = require \audio_node
VS = require \view_style
{sin, cos, pi, pow} = prelude

module.exports = class MixerNode extends Audio
  @desc = "Alters the ratio of two audio sources"
  /** MixerNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   */
  (pos, actx) ->
    super 2 1 pos
    @active-view.set-node-style VS.mixer
    @active-view.set-label "M", \40pt

    @gain-left = actx.create-gain!
    @gain-right = actx.create-gain!
    /* Initially set inputs to be equal */
    @receive-for-ref 0, 0.5

    @inputs.0.audio-node = @gain-left
    @inputs.1.audio-node = @gain-right

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   */
  receive-for-ref: (ref, value) !->
    @gain-left.gain.value = cos(value*pi/2)^2
    @gain-right.gain.value = sin(value*pi/2)^2

  /** (override protected) _connect : void
   *  input : Input
   *
   * Connect this mixer node as the source for the given input.
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
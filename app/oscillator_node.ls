Audio = require \audio_node
VS = require \view_style

module.exports = class OscillatorNode extends Audio
  @desc = "produces note of a given pitch"

  const FREQ_A = 440
  /** OscillatorNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * Creates a node that produces a fixed pitch note
   */
  (pos, actx) ->
    super 0 1, pos
    @active-view.set-node-style VS.oscillator
    @active-view.set-label "O", \40pt
    @active-view.label.fill-color = VS.white-label

    @osc-node = actx.create-oscillator!
    @receive-for-ref 0 0.5
    @osc-node.start 0

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   *
   * Receive the pitch value from the input.
   */
  receive-for-ref: (ref, value) !->
    @osc-node.frequency.value = FREQ_A * 2 ^ (value - 0.75)

  /** (protected override) _connect : void
   *  input : Input
   *
   * Connect the oscillator node to another audio node.
   */
  _connect: (input) !->
    @osc-node.connect input.audio-node

  /** (protected override) _disconnect : void
   *
   * Disconnect from all inputs.
   */
  _disconnect: !->
    @osc-node.disconnect!

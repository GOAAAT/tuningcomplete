Audio = require \audio_node

module.exports = class OscillatorNode extends Audio
  @desc = "produces note of a given pitch"
  /** OscillatorNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * Creates a node that produces a fixed pitch note
   */
  (pos, actx) ->
    super 0 1, pos
    @osc-node = actx.create-oscillator!
    @osc-node.frequency = 440
    @osc-node.start 0

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   *
   * Receive the pitch value from the input.
   */
  receive-for-ref: (ref, value) !->
    @osc-node.frequency = 440 + 200*value

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

FanIn = require \fanin_node
VS = require \view_style

module.exports = class DelayGainNode extends FanIn
  @desc = "Alters the gain over time with delay"

  /** Numerical Input References */
  const GAIN  = 1
  const DELAY = 2

  /** DelayGainNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * Produces a node that changes the gain over a particular time.
   * Both the time and the gain value are modifiable.
   */
  (pos, @actx) ->
    @gain-node = actx.create-gain-node!
    super 2 pos, @gain-node

    @active-view.set-node-style VS.delay-gain
    @active-view.set-label "DG", \32pt

    @receive-for-ref GAIN,  0.5
    @receive-for-ref DELAY, 1

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   */
  receive-for-ref: (ref, value) !->
    switch ref
      | GAIN  => @gain  = 4*value*value
      | DELAY => @delay = value

    now  = @actx.current-time
    gain = @gain-node.gain
    gain.cancel-scheduled-values now
    gain.linear-ramp-to-value-at-time gain.value, now
    gain.linear-ramp-to-value-at-time @gain, now + @delay

  /** (protected override) _connect : void
   *  input : Input
   */
  _connect: (input) !->
    @gain-node.connect input.audio-node

  /** (protected override) _disconnect : void
   */
  _disconnect: !->
    @gain-node.disconnect!


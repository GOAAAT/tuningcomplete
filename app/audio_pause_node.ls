MP3Node = require \mp3_node

module.exports = class AudioPauseNode extends MP3Node
  @desc = "Play an MP3 and start/stop it"

  /** AudioPauseNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * Creates an Audio Node that will pause the source on a 0 signal on its
   * numerical input.
   */
  (pos, @actx) ->
    super pos, @actx
    @start-time = 0
    @start-off  = 0

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Double
   *
   * Start the source on 1 signal, and pause on 0 signal.
   */
  receive-for-ref: (ref, value) !->
    if !!value
      @start-time = @actx.current-time
      @audio-node.start 0, @start-off % @audio-node.buffer.duration
    else
      @audio-node.stop 0
      @start-off += @actx.current-time - @start-time
      @current-time = @audio-node.current-time
      @_refresh-node!

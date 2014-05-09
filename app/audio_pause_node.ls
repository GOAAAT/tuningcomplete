MP3Node = require \mp3_node
VS = require \view_style

module.exports = class AudioPauseNode extends MP3Node
  @desc = "Play an MP3 and start/pause it"

  /** AudioPauseNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * Creates an Audio Node that will pause the source on a 0 signal on its
   * numerical input.
   */
  (pos, @actx) ->
    super pos, @actx
    @started = false
    @start-time = 0
    @start-off  = 0
    @active-view.set-node-style VS.audio-pause
    l = new paper.PointText do
      content: "||"
      font-family: \Helvetica
      font-weight: \bold
      font-size: \40pt
    @active-view.set-label l

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Double
   *
   * Start the source on 1 signal, and pause on 0 signal.
   */
  receive-for-ref: (ref, value) !->
    if !!value
      unless @started
        @started = true
        @start-time = @actx.current-time
        @audio-node.start 0, @start-off % @audio-node.buffer.duration
    else
      if @started
        @audio-node.stop 0
        @start-off += @actx.current-time - @start-time
        @current-time = @audio-node.current-time
        @_refresh-node!
        @started = false

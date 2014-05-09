MP3Node = require \mp3_node
VS = require \view_style

module.exports = class AudioResetNode extends MP3Node
  @desc = "Play an MP3 and start/stop it"

  /** AudioResetNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * Creates a node that will stop the source when its numerical input
   * receives a 0 signal.
   */
  (pos, actx) -> 
    super pos, actx
    @started = false
    @active-view.set-node-style VS.audio-reset
    l = new paper.PointText do
      content: "R"
      font-family: \Helvetica
      font-weight: \bold
      font-size: \40pt
    @active-view.set-label "R", \40pt, false

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   *
   * Start the source on 1 signal, stop it on 0.
   */
  receive-for-ref: (ref, value) !->
    if !!value
      unless @started
        @started = true
        @audio-node.start 0
    else
      if @started
        @audio-node.stop 0
        @_refresh-node!
        @started = false

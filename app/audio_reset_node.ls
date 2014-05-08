MP3Node = require \mp3_node

module.exports = class AudioResetNode extends MP3Node
  @desc = "Play an MP3 and start/stop it"

  /** AudioResetNode
   *  pos : paper.Point
   *  actx : AudioContext
   *
   * Creates a node that will stop the source when its numerical input
   * receives a 0 signal.
   */
  (pos, actx) -> super pos, actx

  /** (override) receive-for-ref : void
   *  ref : Int
   *  value : Float
   *
   * Start the source on 1 signal, stop it on 0.
   */
  receive-for-ref: (ref, value) !->
    if !!value
      @audio-node.start 0
    else
      @audio-node.stop 0
      @_refresh-node!

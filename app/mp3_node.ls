Audio = require \audio_node
VS = require \view_style
{map} = prelude

module.exports = class MP3Node extends Audio
  /** (abstract) MP3Node
   *  pos : paper.Point
   *
   * Creates a node that plays a particular mp3 on loop. This is an
   * abstract class because it doesn't define how to handle the numerical
   * input.
   */
  (pos, @actx) ->
    super 0 1 pos
    @audio-node = @actx.create-buffer-source!
    @audio-node.loop = true

  /** (override) add-to-window : void
   *  win : Window
   *  cb  : Boolean -> ()
   */
  add-to-window: (win, cb) !->
    $uploader = $ \#audio-uploader
    node = this
    # Wait for the uploader to change
    $uploader.on \change ->
      fr = new FileReader!

      # Wait for the reader to load the file
      fr.onload = (e) ->
        # Wait for the context to decode the file data
        node.actx.decode-audio-data @result,
          (buf) ->
            node.audio-node.buffer = buf
            cb true
          (e) -> cb false

      fr.read-as-array-buffer @files.0
      $uploader.off \change

    # Activate the uploader
    $uploader.click!

  /** (protected override) _connect : void
   *  input : Input
   */
  _connect: (input) !-> @audio-node?connect input.audio-node

  /** (protected override) _disconnect : void
   */
  _disconnect: !-> @audio-node?disconnect!

  /** (protected) _refresh-node : void
   *
   * Creates a new Audio Buffer Source Node with the existing buffer.
   */
  _refresh-node: !->
    @_disconnect!
    buf = @audio-node.buffer
    @audio-node = @actx.create-buffer-source!
    @audio-node.buffer = buf
    @audio-node.loop   = true
    @send-list |> map (.input) |> map @~_connect


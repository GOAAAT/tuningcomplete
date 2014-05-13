{each, slice} = prelude
Color = require \color

module.exports = class TextBox
  /** Textbox
   *  content : String
   *  font-size : String
   *  width : Int
   *  @window : Window
   *
   * View class that represents an editable text field. The `content` is the
   * initial content of the field, the `font-size` is the size of the text in the
   * field, and the `width` is the width to display the text field as.
   * `@window` is provided so that when a key is pressed, the view can be forced
   * to update.
   */
  ({
    content   = '',
    font-size = \20pt,
    width     = 100px,
    @window
  }) ->
    size = [ width, 2 * parse-int font-size ]

    @clip-mask = new paper.Shape.Rectangle do
      point: [0px 0px]
      size:  size

    @bg = new paper.Shape.Rectangle do
      point: [0px 0px]
      size:  size
      fill-color: Color.grey

    @text = new paper.PointText do
      font-size: font-size
      fill-color: Color.white

    @group = new paper.Group do
      children: [ @clip-mask, @bg, @text ]
      clipped: true

    @set-text content

  /** view : paper.Item
   *
   * Returns the view representing the text field.
   */
  view: -> @group

  /** set-on-change : void
   *  @_on-change : String -> ()
   *
   * Sets the callback that is called when the field's value changes.
   */
  set-on-change: (@_on-change) !->

  /** expand : void
   *  w : Int
   *
   * Expands the width of the textfield to the given width, `w` whilst
   * maintaining the text in the correct position.
   */
  expand: (w) !->
    { top-center: tc, width: old-w, height: old-h } = @bg.bounds
    [ @clip-mask, @bg ] |> each (.scale w/old-w, 1, tc)
    @_fix-text-align!

  const BACKSPACE = 8 # Backspace character code

  /** set-first-responder : void
   *
   * Set this text field as the one to respond to keyboard events.
   */
  set-first-responder: !->
    $ document .bind \keydown (e) !~>
      content = @text.content
      if e.key-code == BACKSPACE
        e.prevent-default!
        content.slice 0 -1
          |> @set-text
      else
        char = String.from-char-code e.key-code .to-lower-case!
        if \a <= char <= \z or char == ' '
          @set-text content + char

      @_on-change? @text.content
      @window.force-update!

  /** relieve-first-responder : void
   *
   * Ignore keyboard events from now on.
   */
  relieve-first-responder: !->
    $ document .unbind \keydown

  /** set-text : void
   *
   * Set the text displayed in the text field (whilst maintaining its alignment).
   */
  set-text: (content) !->
    @text.content  = content
    @_fix-text-align!

  /** Padding between edge of the field and the text */
  const PAD = 20px

  /** (private) _fix-text-align : void
   *
   * Reposition the text so that the end of the text is visible.
   */
  _fix-text-align: !->
    x-coord =
      if @text.bounds.width < @bg.bounds.width
        @bg.bounds.left + @text.bounds.width / 2 + PAD
      else
        @bg.bounds.right - @text.bounds.width / 2 - PAD

    @text.position = [ x-coord, @bg.bounds.centerY ]

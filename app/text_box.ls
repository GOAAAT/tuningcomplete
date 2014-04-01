{each, slice} = prelude
Color = require \color

module.exports = class TextBox
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

  view: -> @group

  set-on-change: (@_on-change) !->

  expand: (w) !->
    { top-center: tc, width: old-w, height: old-h } = @bg.bounds
    [ @clip-mask, @bg ] |> each (.scale w/old-w, 1, tc)
    @_fix-text-align!

  set-first-responder: !->
    $ document .bind \keydown (e) !~>
      content = @text.content
      if e.key-code == 8 # Backspace
        e.prevent-default!
        content.slice 0 -1
          |> @set-text
      else
        char = String.from-char-code e.key-code .to-lower-case!
        if \a <= char <= \z
          @set-text content + char

      @_on-change? @text.content
      @window.force-update!

  relieve-first-responder: !->
    $ document .unbind \keydown

  set-text: (content) !->
    @text.content  = content
    @_fix-text-align!

  const PAD = 20px

  _fix-text-align: !->
    x-coord =
      if @text.bounds.width < @bg.bounds.width
        @bg.bounds.left + @text.bounds.width / 2 + PAD
      else
        @bg.bounds.right - @text.bounds.width / 2 - PAD

    @text.position = [ x-coord, @bg.bounds.centerY ]

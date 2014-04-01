{each} = prelude
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

    @set-text content

    @group = new paper.Group do
      children: [ @clip-mask, @bg, @text ]
      clipped: true

  view: -> @group

  expand: (w) !->
    { top-center: tc, width: old-w, height: old-h } = @bg.bounds
    [ @clip-mask, @bg ] |> each (.scale w/old-w, 1, tc)
    @_fix-text-align!

  set-text: (content) !->
    @text.content  = content
    @_fix-text-align!

  _fix-text-align: !->
    @text.position =
      [
        @bg.bounds.left + @text.bounds.width / 2 + 20,
        @bg.bounds.centerY
      ]


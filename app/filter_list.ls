{each,empty} = prelude
Color      = require \color
PrefixTree = require \prefix_tree

module.exports = class FilterList
  (ctx, @tag, size = [100px 100px]) ->
    @factory = new RowFactory SimpleRow
    @rows    = []

    @clip-mask = new paper.Shape.Rectangle do
      point: [0px 0px]
      size: size

    @bg = new paper.Shape.Rectangle do
      point: [0px 0px]
      size:  size
      fill-color: Color.black

    @row-group = new paper.Group do
      children: [ @clip-mask ]
      clipped: true

    @group = new paper.Group do
      children: [ @bg, @row-group ]

    # List resize with window callback
    ctx.view.on 'resize' @~_resize

  view: -> @group

  set-data: (@data) ->
    @subset = @data
    @_refresh!

  set-listener: (method) ->
    @_on-select = method @tag, _

  set-visible: (@group.visible) !->

  expand: (w = @bg.bounds.width, h = @_height!) !->
    { top-center: tc, width: old-w, height: old-h } = @bg.bounds
    [ @clip-mask, @bg ] |> each (.scale w/old-w, h/old-h, tc)

  _resize: !-> @expand!

  const PAD = 20px

  _height: ->
    paper.view.bounds.bottom - @bg.bounds.top - PAD

  _refresh: !-> @_clear!; @_populate!

  _clear: !->
    @rows |> each @factory~recycle
    @rows.length = 0

  _populate: !->
    iter = @subset.iterator!
    until iter.is-done!
      iter.next!
        |> @factory.build-row
        |> @_insert

  _insert: (row) ->
    row.view!position =
      @bg.bounds.top-center.add [
        (row.view!bounds.width - @bg.bounds.width) / 2 + PAD,
        row.height * (@rows.length + 0.5) + PAD
      ]

    @rows.push row
    @row-group.add-child row.view!

class RowFactory
  const MAX_POOL = 10
  (@Row) ->
    @pool = []

  build-row: (details) ->
    row =
      if empty @pool then new @Row!
      else @pool.pop!

    row.build details
    row

  recycle: (row) !->
    row.view!remove!
    if @pool.length < MAX_POOL
      @pool.push row

class SimpleRow
  @::height = 100px

  ->
    @title = new paper.PointText do
      content: "Title"
      font-size: \25pt
      font-weight: \bold
      fill-color: Color.white

    @sub-title = new paper.PointText do
      content: "Subtitle"
      font-size: \15pt
      fill-color: Color.white

    @sub-title.position = [0px 30px]

    @group = new paper.Group do
      children: [ @title, @sub-title ]

  view: -> @group

  build: ([name, {desc}:obj]) !->
    @obj               = obj
    @title.content     = name.to-upper-case!
    @sub-title.content = desc

    @title.pivot      = @title.bounds.center-left
    @title.position.x = @group.parent.bounds.left

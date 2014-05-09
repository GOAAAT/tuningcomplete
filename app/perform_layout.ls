CursorResponder = require \cursor_responder
SliderView = require \slider_view
ToggleView = require \toggle_view
XYSliderView = require \xy-slider_view
PointInfo = require \point_info

{map, filter, each, head, empty} = prelude

module.exports = class PerformLayout extends CursorResponder
  const XYSLIDERS = 1
  const SLIDERS   = 5
  const TOGGLES   = [12 12 12]

  const TOGGLE_PAD = 1 / 8

  const SLIDER_DIM = [0.1   0.6]
  const XY_DIM     = [0.5   0.575]
  const TOGGLE_DIM = [1/TOGGLES[0], 0.4 * 1 / TOGGLES.length]

  const OFFSET = 101

  /** PerformLayout
   *  ctx : paper.PaperScope
   *
   * Creates a view for the performance stage.
   */
  (ctx) ->
    @layer = new ctx.Layer!

    @layer.visible     = false
    @layer.data.locked = false

    bg = new paper.Shape.Rectangle ctx.view.bounds
    bg.fill-color = new paper.Color 0.3 0.8
    @layer.add-child bg

    ctx.view.on \resize -> bg.bounds = ctx.view.bounds

    slider-dim = ctx.view.bounds.size.subtract [0, OFFSET] .multiply SLIDER_DIM
    slider-y   = (slider-dim.height / 2) + OFFSET

    toggle-dim = ctx.view.bounds.size.subtract [0, OFFSET] .multiply TOGGLE_DIM

    xy-slider-dim = ctx.view.bounds.size.subtract [OFFSET/2, 0] .multiply XY_DIM

    @sliders =
      for i from 0 til SLIDERS
        slider =
          new SliderView do
            [slider-dim.width*(i+0.5), slider-y]
            slider-dim
            i

        slider.item!visible = false
        @layer.add-child slider.item!
        slider

    @toggles = []

    for j from 0 til TOGGLES.length
      toggle-y = slider-dim.height + OFFSET + toggle-dim.height * (j)
      for i from 0 til TOGGLES[j]
        toggle =
          new ToggleView do
            [toggle-dim.width*(i+TOGGLE_PAD), toggle-y]
            toggle-dim
            i + (j * TOGGLES[0])

        toggle.item!visible = false
        @layer.add-child toggle.item!
        @toggles.push toggle

    @xyslider =
      new XYSliderView do
        [slider-dim.width*SLIDERS, OFFSET/4]
        xy-slider-dim
        0
    @responders = []

    @xyslider.item!visible = false
    @layer.add-child @xyslider.item!

  /** show : void
   *  visible : Boolean
   *
   * Determines whether the perform layer is visible or not.
   */
  show: (@layer.visible) !->
    @responder = null

  /** lock : void
   *  locked : Boolean
   *
   * Determines whether the input elements can be modified or not.
   */
  lock: (@layer.data.locked) !->

  /** is-locked : Boolean
   *
   * Returns whether the layer is locked or not.
   */
  is-locked: -> @layer.data.locked

  /** request-input-for-type : View
   *  type : String
   *
   * Returns a free input for the given type.
   */
  request-input-view-for-type: (type) ->
    switch type
      | \Slider   =>
        slider = @sliders.shift!
        slider?item!visible = true
        slider
      | \Toggle   =>
        toggle = @toggles.shift!
        toggle?item!visible = true
        toggle
      | \XY-Slider =>
        xy-slider = @xyslider
        @xyslider = null
        xy-slider?item!visible = true
        xy-slider
      | otherwise => null

  /** CursorResponder methods */

  /** select-at : Boolean
   *  pt : paper.Point
   *
   * A select event was made at this position.
   */
  select-at: (pt) ->
    return true unless @layer.visible

    @_find-item pt ?.item
      |> @_find-significant-parent
      |> (?select-at pt)

    return false

  /** pointer-down : Boolean
   *  pt : paper.Point
   *
   * The pointer has gone down at the given position.
   */
  pointer-down: (pt) ->
    return !@layer.visible

  /** pointer-moved : Boolean
   *  pt : paper.Point
   *
   * The pointer has moved to the given position.
   */
  pointer-moved: (pt) ->
    return !@layer.visible

  /** pointer-up : Boolean
   *  pt : paper.Point
   *
   * The pointer was released at the given position.
   */
  pointer-up: (pt) ->
    return !@layer.visible

  /** pointers-changed (pt-infos: [PointInfo]) : void
   *  Moves sliders/activates buttons in perform stage
   */
  pointers-changed: (pt-infos) ->
    return true unless @layer.visible
    return false unless @layer.data.locked
    #list of selected responders e.g sliders
    new-responders = pt-infos
      |> filter (pt-info) -> pt-info.type == \finger || pt-info.type == \drag
      |> map (pt-info) ~>
        if pt-info.z < 6
          responder =
            @_find-item pt-info.pt ?.item
              |> @_find-significant-parent
          if responder?
            return new Responder responder, pt-info.pt
        else return new Responder undefined, undefined
      |> filter (?)
      |> filter (.responder?)

    #call pointer-moved/pointer-down on each of the currently selected responders
    new-responders
      |> each (responder) !~>
        prev-responder = @responders
          |> filter (.responder == responder.responder)
          |> filter (.up)
          |> each (old-responder) !-> old-responder.up = false
          |> head
        if prev-responder?
          responder.responder.pointer-moved responder.pt
        else
          responder.responder.pointer-down responder.pt

    #update previous frame responders if they're no longer selected
    @responders
      |> each (responder) !->
        if responder.up
          responder.responder.pointer-up responder.pt

    @responders = new-responders

  /** Private methods */
  const HIT_TOLERANCE = 50

  /** (private) _find-item : paper.HitResult
   *  pt : paper.Point
   *
   * Performs a hit test at the point and returns the HitResult.
   */
  _find-item: (pt) ->
    @layer?hit-test pt, do
     fill:      true
     stroke:    true
     tolerance: HIT_TOLERANCE

  /** (private) _find-significant-parent : View
   *  item : paper.Item
   *
   * Find the closest ancestor of the given item that belongs to a view
   * (A NodeView or a WireView).
   */
  _find-significant-parent: (item) ->
    while item and not item.data.obj?
      item = item.parent

    item?data?obj


  class Responder
    (@responder,@pt)->
      @up = true

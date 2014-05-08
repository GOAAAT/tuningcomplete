CursorResponder = require \cursor_responder
SliderView = require \slider_view
ToggleView = require \toggle_view

module.exports = class PerformLayout extends CursorResponder
  const XYSLIDERS = 1
  const SLIDERS   = 8
  const TOGGLES   = [12 12]

  const TOGGLE_PAD = 1 / 8

  const SLIDER_DIM = [0.1   0.6]
  const XY_DIM     = [0.5   0.6]
  const TOGGLE_DIM = [1/TOGGLES[0], 0.2]
  
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
    
    for j from 0 til 2
      toggle-y = slider-dim.height + OFFSET + toggle-dim.height * (j)
      for i from 0 til TOGGLES[j]
        toggle =
          new ToggleView do
            [toggle-dim.width*(i+TOGGLE_PAD), toggle-y]
            toggle-dim
            i
      
        toggle.item!visible = false
        @layer.add-child toggle.item!
        @toggles.push toggle
      
    console.log \TOGGLES @toggles

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
    return true unless @layer.visible

    @responder =
      @_find-item pt ?.item
        |> @_find-significant-parent

    @responder?pointer-down pt
    return false

  /** pointer-moved : Boolean
   *  pt : paper.Point
   *
   * The pointer has moved to the given position.
   */
  pointer-moved: (pt) ->
    return true unless @layer.visible

    new-responder =
      @_find-item pt ?.item
        |> @_find-significant-parent

    if new-responder != @responder
      @responder?pointer-up pt
      new-responder?pointer-down pt
      @responder = new-responder
    else
      @responder?pointer-moved pt

    return false

  /** pointer-up : Boolean
   *  pt : paper.Point
   *
   * The pointer was released at the given position.
   */
  pointer-up: (pt) ->
    return true unless @layer.visible

    @responder?pointer-up pt
    @responder = null
    return false

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

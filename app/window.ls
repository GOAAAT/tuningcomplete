CursorResponder = require \cursor_responder
{Node,Input,Output} = require \node

module.exports = class Window extends CursorResponder
  (canvas) ->
    @ctx = new paper.PaperScope()
    @ctx.setup(canvas)

  activate: -> @ctx.activate!
  add-subview: (sub, pos = 0) ->
    @ctx?project?active-layer?insert-child sub, pos

  /** CursorResponder methods */

  select-at: (pt) !->
    @_find-item pt ?.item?selected!

  scale-by: (sf, pt) !->
    delta = @ctx.view.center.subtract pt
    @ctx.view.zoom *= sf
    delta.multiply 1 - sf |> @ctx.view.scroll-by

  pointer-down: (pt) !->
    item = @_snap-item pt ?.item

    if item instanceof Output
      @active-wire = new Wire(item)
      @active-wire?view! |> @add-subview

  pointer-moved: (pt) !->
    @active-wire?set-end pt

  pointer-up: (pt) !->
    item = @_snap-item pt ?.item

    if item instanceof Input and @active-wire?
      item.connect @active-wire
    else
      @active-wire?view?remove!

  pan-by: (delta) !->
    @ctx?view?scroll-by delta

  /** Private methods */
  const HIT_TOLERANCE  = 20
  const SNAP_TOLERANCE = 40

  _snap-item: (pt, tol = SNAP_TOLERANCE) ->
    @ctx?project?hit-test pt, do
      fill:      true
      stroke:    true
      selected:  true
      tolerance: tol

  _find-item: (pt, tol = HIT_TOLERANCE) ->
    @ctx?project?hit-test pt, do
      fill:      true
      stroke:    true
      tolerance: tol

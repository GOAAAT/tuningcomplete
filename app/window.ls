CursorResponder = require \cursor_responder
{Node,Input,Output} = require \node

module.exports = class Window extends CursorResponder
  (canvas) ->
    @ctx = new paper.PaperScope()
    @ctx.setup(canvas)

  /** activate : void
   *
   * Make this window the active (default) one
   */
  activate: !-> @ctx.activate!

  /** add-subview : paper.Item
   *  sub : paper.Item,
   *  pos : Int
   *
   * Add subview `sub` at position `pos`, returns the inserted item, or null
   * on failure
   */
  add-subview: (sub, pos = 0) ->
    @ctx?project?active-layer?insert-child sub, pos

  /** CursorResponder methods */

  /** select-at : void
   *  pt : paper.Point
   *
   * Notify the item nearest to the point that it has been selected.
   */
  select-at: (pt) !->
    @_find-item pt ?.item?selected!

  /** scale-by : void
   *  sf : Float,
   *  pt : paper.Point
   *
   * Scale about the given position `pt` by the provided scale factor `sf`.
   */
  scale-by: (sf, pt) !->
    delta = @ctx.view.center.subtract pt
    @ctx.view.zoom *= sf
    delta.multiply 1 - sf |> @ctx.view.scroll-by

  /** pointer-down : void
   *  pt : paper.Point
   *
   * If the pointer goes down near an output, start a new wire.
   */
  pointer-down: (pt) !->
    item = @_snap-item pt ?.item

    if item instanceof Output
      @active-wire = new Wire(item)
      @active-wire?view! |> @add-subview

  /** pointer-moved : void
   *  pt : paper.Point
   *
   * Update the end of the currently active wire.
   */
  pointer-moved: (pt) !->
    @active-wire?set-end pt

  /** pointer-up : void
   *  pt : paper.Point
   *
   * If the pointer is released near an Input of a Node, then connect
   * the wire to it.
   */
  pointer-up: (pt) !->
    item = @_snap-item pt ?.item

    if item instanceof Input and @active-wire?
      item.connect @active-wire
    else
      @active-wire?view?remove!

  /** pan-by : void
   *  delta : paper.Point
   *
   * Scroll the entire view by the given vector
   */
  pan-by: (delta) !->
    @ctx?view?scroll-by delta

  /** Private methods */
  const HIT_TOLERANCE  = 20
  const SNAP_TOLERANCE = 40

  /** (private) _snap-item : paper.HitResult
   *  pt : paper.Point
   *  (optional) tol : Float
   *
   * Searches for the nearest *selected* item within `tol` distance of `pt`.
   * Returns a HitResult detailing the information if something was hit, or
   * `null` otherwise.
   */
  _snap-item: (pt, tol = SNAP_TOLERANCE) ->
    @ctx?project?hit-test pt, do
      fill:      true
      stroke:    true
      selected:  true
      tolerance: tol

  /** (private) _find-item : paper.HitResult
   *  pt : paper.Point
   *  (optional) tol : Float
   *
   * Searches for the nearest item within `tol` distance of `pt`. Returns a
   * HitResult detailing the information if something was hit, or `null`
   * otherwise.
   */
  _find-item: (pt, tol = HIT_TOLERANCE) ->
    @ctx?project?hit-test pt, do
      fill:      true
      stroke:    true
      tolerance: tol

CursorResponder = require \cursor_responder
{Node,Input,Output} = require \node

module.exports = class Window extends CursorResponder
  /** Window
   *  canvas : HTMLCanvasElement
   *
   * View class for the entire app and entry point for cursor events.
   */
  (canvas) ->
    @ctx = new paper.PaperScope()
    @ctx.setup(canvas)

    @view-layer = @ctx.project.active-layer
    @ui-layer   = new @ctx.Layer!

    @view-layer.activate!

  /** activate : void
   *
   * Make this window the active (default) one
   */
  activate: !-> @ctx.activate!

  /** force-update : void
   *
   * Make the renderer force a screen refresh.
   */
  force-update: !-> @ctx.view.draw!

  /** insert-ui : [paper.Item]
   *  sub : [paper.Item],
   *  pos : Int
   *
   * Adds children `sub` to the UI layer (above the view layer), returning the
   * inserted items, or null on failure.
   */
  insert-ui: (sub, pos = 0) ->
    @ui-layer?insert-children pos, sub

  /** insert-children : [paper.Item]
   *  sub : [paper.Item],
   *  pos : Int
   *
   * Add children `sub` at position `pos`, returns the inserted items, or null
   * on failure.
   */
  insert-children: (sub, pos = 0) ->
    @view-layer?insert-children pos, sub

  /** CursorResponder methods */

  /** select-at : void
   *  pt : paper.Point
   *
   * Notify the item nearest to the point that it has been selected.
   */
  select-at: (pt) !->
    @_find-item pt ?.item?fire 'doubleclick'

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
      [ @active-wire?view! ] |> @insert-children

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
   * on the wire to this Node
   */
  pointer-up: (pt) !->
    item = @_snap-item pt ?.item

    @active-wire?view?remove! unless item instanceof Input and 
    @active-wire? and 
    @active-wire.connect item

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

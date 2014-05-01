CursorResponder = require \cursor_responder
Node = require \node
NodeView = require \node_view
WireView = require \wire_view
Input = require \input
PointInfo = require \point_info
VS = require \view_style
{map, each} = prelude

module.exports = class Window extends CursorResponder
  /** Window
   *  canvas : HTMLCanvasElement
   *
   * View class for the entire app and entry point for cursor events.
   */
  (canvas) ->
    @ctx = new paper.PaperScope()
    @ctx.setup(canvas)

    @sf = 1

    @view-layer   = @ctx.project.active-layer
    @ui-layer     = new @ctx.Layer!
    @cursor-layer = new @ctx.Layer!

    @moveable-layers = [@view-layer]

    @view-layer.activate!

    @wire-group = new @ctx.Group!
    @insert-children [@wire-group], 0

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

  /** insert-cursor : [paper.Item]
   *  sub : [paper.Item],
   *  pos : Int
   *
   * Adds children `sub` to the cursor layer (above all layers), returning the
   * inserted items, or null on failure.
   */
  insert-cursor: (sub, pos = 0) ->
    @cursor-layer?insert-children pos, sub

  /** insert-children : [paper.Item]
   *  sub : [paper.Item],
   *  pos : Int
   *
   * Add children `sub` at position `pos`, returns the inserted items, or null
   * on failure.
   */
  insert-children: (sub, pos = 1) ->
    @_correct-scaling sub
    @view-layer?insert-children pos, sub

  /** insert-wire : [paper.Item]
   *  sub : [paper.Item],
   *  pos : Int
   *
   * On the wire layer, add children `sub` at position `pos`,
   * returns the inserted items, or null on failure.
   */
  insert-wire: (sub, pos = 0) ->
    @_correct-scaling sub
    @wire-group?insert-children pos, sub

  /** CursorResponder methods */

  /** select-at : void
   *  pt : paper.Point
   *
   * Notify the item nearest to the point that it has been selected.
   */
  select-at: (pt) !->
    selected =
      @_find-item pt ?.item
        |> @_find-significant-parent

    console.log selected

    @active-node-view?deselect!
    @active-wire-view?deselect!

    if selected instanceof NodeView
      @active-node-view = selected
      @active-node-view?select!
    else if selected instanceof WireView

      # Selecting an already selected wire will disconnect it
      if @active-wire-view == selected
        @active-wire-view.owner.disconnect!
        @active-wire-view = undefined
      else
        @active-wire-view = selected

      @active-wire-view?select!

  /** scale-by : void
   *  sf : Float,
   *  pt : paper.Point
   *
   * Scale about the given position `pt` by the provided scale factor `sf`.
   */
  scale-by: (sf, pt) !->
    @sf *= sf
    @moveable-layers |> map (l) -> l.scale sf, pt
    @force-update!

  /** pointer-down : void
   *  pt : paper.Point
   *
   * If the pointer goes down near an output, start a new wire.
   */
  pointer-down: (pt) !->
    item = @_snap-item pt ?.item

    if item instanceof Node
      @active-wire = new Wire(item)
      [ @active-wire?active-view! ] |> @insert-children

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
    @moveable-layers |> map (.translate delta.negate!)
    @force-update!

  /** pointers-changed : void
   *  pt-infos : [PointInfo]
   *
   * Update the position of the cursors on screen.
   */
  pointers-changed: (pt-infos) !->
    @cursor-layer.remove-children!
    pt-infos
      |> map VS.view-style-for-pointers
      |> @insert-cursor

    @force-update!

  /** Private methods */
  const HIT_TOLERANCE  = 50
  const SNAP_TOLERANCE = 100

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

  /** (private) _correct-scaling : void
   *  items : [paper.Item]
   *
   * Match the scaling of the items to the scaling of the view.
   */
  _correct-scaling: (items) !->
    items |> each (item) ~> item.scale @sf / item.scaling.x

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

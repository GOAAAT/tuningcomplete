CursorResponder = require \cursor_responder
Node = require \node
Wire = require \wire
NodeView = require \node_view
WireView = require \wire_view
Input = require \input
PointInfo = require \point_info
VS = require \view_style
Button = require \button
{map, each} = prelude

module.exports = class Window extends CursorResponder
  /** Window
   *  canvas : HTMLCanvasElement
   *
   * View class for the entire app and entry point for cursor events.
   */
  (canvas) ->
    @ctx = new paper.PaperScope!
    @ctx.setup canvas

    @sf = 1

    @view-layer    = @ctx.project.active-layer
    @perform-layer = new @ctx.Layer!
    @ui-layer      = new @ctx.Layer!
    @cursor-layer  = new @ctx.Layer!

    @moveable-layers = [@view-layer]

    @view-layer.activate!
    @perform-layer.visible = false
    @perform-layer.data.locked = false

    @wire-group = new @ctx.Group!
    @insert-children [@wire-group], 0

    perform-bg = new paper.Shape.Rectangle @ctx.view.bounds
    perform-bg.fill-color = new paper.Color 0.3 0.8
    @insert-perform [perform-bg], 0

    @ctx.view.on \resize ~> perform-bg.bounds = @ctx.view.bounds

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

  /** insert-perform : [paper.Item]
   *  sub : [paper.Item]
   *  pos : Int
   *
   * Add children `sub` to the perform layer at position `pos`, returns the
   * inserted items, or null on failure.
   */
  insert-perform: (sub, pos = 1) ->
    console.log sub.name
    @perform-layer?insert-children pos, sub

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

  /** show-perform : void
   *  state : Boolean
   *
   * Set the performance layer as visible or not.
   */
  show-perform: (@perform-layer.visible) !->
    @perform-responder = null
    @force-update!

  /** lock-perform : void
   *  state : Boolean
   *
   * Set the performance layer as locked or not. If it is locked, the
   * 'stickiness' of its UI elements cannot be modified.
   */
  lock-perform: (@perform-layer.data.locked) !->

  /** CursorResponder methods */

  /** select-at : void
   *  pt : paper.Point
   *
   * Notify the item nearest to the point that it has been selected.
   */
  select-at: (pt) !->
    button =
      @_find-item pt, @ui-layer ?.item
        |> @_find-significant-parent

    if button?
      button.trigger true
      return

    if @perform-layer.visible
      @_find-item pt, @perform-layer ?.item
        |> @_find-significant-parent
        |> (?select-at pt)
      return

    selected =
      @_find-item pt ?.item
        |> @_find-significant-parent

    @active-node-view?deselect!
    @active-wire-view?deselect!

    @active-node-view =
      if selected instanceof NodeView then selected else undefined

    if @active-wire-view == selected
      @active-wire-view?owner.disconnect!
      @active-wire-view = undefined
    else
      @active-wire-view =
        if selected instanceof WireView then selected else undefined

    @active-node-view?select!
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
    if @perform-layer.visible
      @perform-responder =
        @_find-item pt, @perform-layer ?.item
          |> @_find-significant-parent

      @perform-responder?pointer-down pt
      return

    view =
      @_find-item pt ?.item
        |> @_find-significant-parent

    if view instanceof NodeView and view.owner.has-output!
      @current-wire = new Wire view.owner
      @insert-wire [ @current-wire?view! ]

  /** pointer-moved : void
   *  pt : paper.Point
   *
   * Update the end of the currently active wire.
   */
  pointer-moved: (pt) !->
    if @perform-layer.visible
      new-responder =
        @_find-item pt, @perform-layer ?.item
          |> @_find-significant-parent

      if new-responder != @perform-responder
        @perform-responder?pointer-up pt
        new-responder?pointer-down pt
        @perform-responder = new-responder
      else
        @perform-responder?pointer-moved pt

      return

    @current-wire?active-view.set-end pt

  /** pointer-up : void
   *  pt : paper.Point
   *
   * If the pointer is released near an Input of a Node, then connect
   * on the wire to this Node
   */
  pointer-up: (pt) !->
    if @perform-layer.visible
      @perform-responder?pointer-up pt
      @perform-responder = null
      return

    view =
      @_find-item pt ?.item
        |> @_find-significant-parent

    connected =
      view instanceof NodeView and
      @current-wire?connect view.owner

    @current-wire?view!remove! unless connected
    @current-wire = undefined

  /** pan-by : void
   *  delta : paper.Point
   *
   * Scroll the entire view by the given vector
   */
  pan-by: (delta) !->
    dn = delta.negate!
    if @active-node-view?
      @active-node-view.owner.translate dn
    else
      @moveable-layers |> map (.translate dn)

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

  /** (private) _find-item : paper.HitResult
   *  pt : paper.Point
   *  (optional) tol : Float
   *
   * Searches for the nearest item in `layer` to `pt` within a tolerance.
   * Returns a HitResult detailing the information if something was hit, or
   * `null` otherwise.
   */
  _find-item: (pt, layer = @view-layer) ->
    layer?hit-test pt, do
      fill:      true
      stroke:    true
      tolerance: HIT_TOLERANCE

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

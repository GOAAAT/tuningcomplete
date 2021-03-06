CursorResponder = require \cursor_responder
Node = require \node
Wire = require \wire
NodeView = require \node_view
WireView = require \wire_view
Input = require \input
PointInfo = require \point_info
VS = require \view_style
Button = require \button
PerformLayout = require \perform_layout
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

    @locked = false
    @sf = 1

    @view-layer     = @ctx.project.active-layer
    @perform-layout = new PerformLayout @ctx
    @ui-layer       = new @ctx.Layer!
    @cursor-layer   = new @ctx.Layer!

    @moveable-layers = [@view-layer]

    @view-layer.activate!

    @wire-group = new @ctx.Group!
    @insert-children [@wire-group], 0

  /** lock (locked) : void
   *
   * Lock the window to prevent pan and scale
   */
  lock: (@locked) !->

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

  /** deselect: void
   *  Deselect any selected nodes/wires
   */
  deselect: !->
    @active-node-view?deselect!
    @active-node-view = undefined
    @active-wire-view?deselect!
    @active-wire-view = undefined

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

  /** show-perform : void
   *  state : Boolean
   *
   * Set the performance layer as visible or not.
   */
  show-perform: (state) !->
    @perform-layout.show state
    @force-update!

  /** lock-perform : void
   *  state : Boolean
   *
   * Set the performance layer as locked or not. If it is locked, the
   * 'stickiness' of its UI elements cannot be modified.
   */
  lock-perform: (locked) !-> @perform-layout.lock locked

  /** request-input-for-type : View
   *  type : String
   *
   * Returns a free input of the given type, if one exists.
   */
  request-input-view-for-type: (type) ->
    @perform-layout.request-input-view-for-type type

  /** CursorResponder methods */

  /** select-at : Boolean
   *  pt : paper.Point
   *
   * Notify the item nearest to the point that it has been selected.
   */
  select-at: (pt) ->
    button =
      @_find-item pt, @ui-layer ?.item
        |> @_find-significant-parent

    if button?
      @deselect!
      button.trigger true
      return

    return false unless @perform-layout.select-at pt

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
    return false

  /** scale-by : Boolean
   *  sf : Float,
   *  pt : paper.Point
   *
   * Scale about the given position `pt` by the provided scale factor `sf`.
   */
  scale-by: (sf, pt) ->
    unless @locked
      @sf *= sf
      @moveable-layers |> map (l) -> l.scale sf, pt
      @force-update!
      return false

  /** pointer-down : Boolean
   *  pt : paper.Point
   *
   * If the pointer goes down near an output, start a new wire.
   */
  pointer-down: (pt) ->
    return false unless @perform-layout.pointer-down pt

    view =
      @_find-item pt ?.item
        |> @_find-significant-parent

    if view instanceof NodeView and view.owner.has-output!
      @current-wire = new Wire view.owner
      @insert-wire [ @current-wire?view! ]

    return false

  /** pointer-moved : Boolean
   *  pt : paper.Point
   *
   * Update the end of the currently active wire.
   */
  pointer-moved: (pt) ->
    return false unless @perform-layout.pointer-moved pt

    @current-wire?active-view.set-end pt
    return false

  /** pointer-up : Boolean
   *  pt : paper.Point
   *
   * If the pointer is released near an Input of a Node, then connect
   * on the wire to this Node
   */
  pointer-up: (pt) ->
    return false unless @perform-layout.pointer-up pt

    view =
      @_find-item pt ?.item
        |> @_find-significant-parent

    connected =
      view instanceof NodeView and
      @current-wire?connect view.owner

    @current-wire?view!remove! unless connected
    @current-wire = undefined
    return false

  /** pan-by : Boolean
   *  delta : paper.Point
   *
   * Scroll the entire view by the given vector
   */
  pan-by: (delta) ->
    unless @locked
      dn = delta.negate!
      if @active-node-view?
        @active-node-view.owner.translate dn
      else
        @moveable-layers |> map (.translate dn)

      @force-update!
      return false

  /** pointers-changed : Boolean
   *  pt-infos : [PointInfo]
   *
   * Update the position of the cursors on screen.
   */
  pointers-changed: (pt-infos) ->
    @perform-layout.pointers-changed pt-infos
    @cursor-layer.remove-children!
    pt-infos
      |> map VS.view-style-for-pointers
      |> @insert-cursor

    @force-update!
    return false

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

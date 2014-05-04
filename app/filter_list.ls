{each,empty} = prelude
Color      = require \color
TextBox    = require \text_box
PrefixTree = require \prefix_tree

module.exports = class FilterList
  /** FilterList
   *  win : Window
   *  tag : Object
   *  size : Size
   *
   * View class for a table view that can be filtered by prefixes.
   */
  (win, @tag, size = [100px 100px]) ->
    @factory = new RowFactory SimpleRow
    @rows    = []

    # Rectangle that clips the rows to be contained
    # in the background.
    @clip-mask = new paper.Shape.Rectangle do
      point: [0px 0px]
      size: size

    @bg = new paper.Shape.Rectangle do
      point: [0px 0px]
      size:  size
      fill-color: Color.black

    # Group that all the rows are inserted into.
    @row-group = new paper.Group do
      children: [ @clip-mask ]
      clipped: true

    @text-box = new TextBox do
      window: win
      content: ''
      font-size: \30pt
      width: 200px

    @text-box.view!position =
      @bg.bounds.top-center.add [0 PAD + @text-box.view!bounds.height / 2 ]

    @text-box.set-on-change @~_filter-did-change

    @group = new paper.Group do
      children: [ @bg, @row-group, @text-box.view! ]

    # List resize with window callback
    win.ctx.view.on 'resize' @~_resize

  /** view : paper.Item
   *
   * Returns the paperjs Item that represents the FilterList.
   */
  view: -> @group

  /** set-data : void
   *  @data : PrefixTree
   *
   * Set the list from which to display the data from, and updates the view
   * to reflect the change.
   */
  set-data: (@data) !->
    @subset = @data
    @_refresh!

  /** set-listener : void
   *  method : Object -> (String, Class) -> ()
   *
   * Sets the listener that gets called when a row is selected. It expects the
   * method to take the FilterList's tag, the name of the selected row, and the
   * object that the selected row represents (in that order), the return result
   * will be ignored.
   */
  set-listener: (method) !->
    @_on-select = method @tag, _

  /** set-visible : void
   *  @group.visible : Boolean
   *
   * Set whether the list is visible or not.
   */
  set-visible: (@group.visible) !->
    if @group.visible
      @text-box.set-first-responder!
    else
      @text-box.relieve-first-responder!

  /** expand : void
   *  w : Int
   *  h : Int
   *
   * Expand the size of the mask and the background to the given width and
   * height. By default the width is set to the current width, and the height is
   * set to be the as big as the available screen space.
   */
  expand: (w = @bg.bounds.width, h = @_height!) !->
    { top-center: tc, width: old-w, height: old-h } = @bg.bounds
    [ @clip-mask, @bg ] |> each (.scale w/old-w, h/old-h, tc)
    @text-box.expand w - 2 * PAD

  /** (private) _resize : void
   *
   * The callback that is called when the view is resized.
   */
  _resize: !-> @expand!

  /** Padding between list and rows */
  const PAD = 20px

  /** (private) _height : Int
   *
   * The maximal height that the view can be.
   */
  _height: ->
    paper.view.bounds.bottom - @bg.bounds.top - PAD

  /** (private) _refresh : void
   *
   * Redraw the rows with the latest dataset.
   */
  _refresh: !-> @_clear!; @_populate!

  /** (private) _clear : void
   *
   * Remove all the row views from the list.
   */
  _clear: !->
    @rows |> each @factory~recycle
    @rows.length = 0

  /** (private) _populate : void
   *
   * Create and add the row views to the list view for the items in the current
   * dataset.
   */
  _populate: !->
    iter = @subset.iterator!
    until iter.is-done!
      iter.next!
        |> @factory.build-row
        |> @_insert

  /** (private) _insert : void
   *  row : Object
   *
   * Append the provided row to the end of the list.
   */
  _insert: (row) !->
    row.view!position =
      @bg.bounds.top-center.add [
        (row.view!bounds.width - @bg.bounds.width) / 2 + PAD,
        @text-box.view!bounds.height +
          row.height * (@rows.length + 0.5) + PAD
      ]

    row.set-listener @~_did-select-row-with-data

    @rows.push row
    @row-group.add-child row.view!

  /** (private) _did-select-row-with-data : void
   *  data : Object
   *
   * Method called by a row when it is selected.
   */
  _did-select-row-with-data: (data) !-> @_on-select? data

  /** (private) _filter-did-change : void
   *  filter-str : String
   *
   * Callback called when the textbox's value changes. It is used to update the
   * filtered list of items, based on the prefix provided
   */
  _filter-did-change: (filter-str) !->
    @subset = @data.filter filter-str or @data
    @_refresh!

class RowFactory
  /** (private) RowFactory
   *  @Row : Class
   *
   * Factory class that creates instances of the provided @Row class. And also
   * provides the facility to recycle row views, instead of creating new ones.
   */
  (@Row) ->
    @pool = []

  /** build-row : @Row
   *  details : (String, Object)
   *
   * Returns a row instance with the given `details`.
   */
  build-row: (details) ->
    row =
      if empty @pool then new @Row!
      else @pool.pop!

    row.build details
    row

  /** The maximum number of row instances to keep in the cache */
  const MAX_POOL = 0

  /** recycle : void
   *  row : @Row
   *
   * Notify the Factory that the provided instance, `row` is no longer being
   * used.
   */
  recycle: (row) !->
    row.view!remove!
    if @pool.length < MAX_POOL
      @pool.push row

class SimpleRow
  /** Height of the row for indexing calculations */
  @::height = 100px

  /** (private) SimpleRow
   *
   * View class for a row.
   */
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

    @text = new paper.Group do
      children: [ @title, @sub-title ]

    @hit-box = new paper.Shape.Rectangle do
      fill-color: Color.black
      opacity: 0

    @group = new paper.Group do
      children: [ @text, @hit-box ]
    @group.data.obj = this

    @hit-box.on 'mouseenter' @~_on-mouse-enter
    @hit-box.on 'mouseleave' @~_on-mouse-leave
    @hit-box.on 'mousedown'  @~_on-mouse-down
    @hit-box.on 'mouseup'    @~_on-mouse-up

  /** view : paper.Item
   *
   * The view representing the row.
   */
  view: -> @group

  /** set-listener : void
   *  @_on-select : (String, Object) -> ()
   *
   * Sets the method that gets called when the row is selected.
   * It is passed the data that the row was built with (the provided name and
   * object).
   */
  set-listener: (@_on-select) !->

  /*
  *  Activate the row's select function
  */
  trigger: !->
    if @_on-select?
      @_on-select @data

  /** build : void
   *  name : String
   *  obj : Object
   *  desc : String
   *
   * Sets the title, subtitle and data attributes of the row to the ones
   * provided, and updates the view accordingly.
   */
  build: ([name, {desc}:obj]) !->
    @data              = [name, obj]
    @title.content     = name.to-upper-case!
    @sub-title.content = desc

    @title.pivot      = @title.bounds.center-left
    @title.position.x = @group.parent.bounds.left

    @sub-title.pivot      = @sub-title.bounds.center-left
    @sub-title.position.x = @group.parent.bounds.left

    @hit-box.position = @text.bounds.center
    @hit-box.size     = @text.bounds.size

  /** (private) _on-mouse-enter : void
   *
   * Callback that is called when the mouse enters into the hitbox region of the
   * row.
   */
  _on-mouse-enter: !->
    @text.fill-color = Color.blue

  /** (private) _on-mouse-leave : void
   *
   * Callback that is called when the mouse leaves the hitbox region of the row.
   */
  _on-mouse-leave: !->
    @text.fill-color = Color.white

  /** (private) _on-mouse-leave : void
   *
   * Callback that is called when the mouse is pressed down in the hitbox region
   * of the row.
   */
  _on-mouse-down: !->
    @text.fill-color = Color.green

  /** (private) _on-mouse-up : void
   *
   * Callback that is called when the mouse is released in the hitbox region of
   * the row.
   */
  _on-mouse-up: !->
    @_on-mouse-leave!
    @_on-select? @data

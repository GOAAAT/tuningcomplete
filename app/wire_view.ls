VS = require \view_style
Colour = require \color

/** Public Methods Summary
 *
 * WireView(start, type)
 * -- sets up initial values of the wire
 *
 * item()
 * -- returns the wire item
 *
 * set-wire-type(type)
 * -- sets the wire type and style
 *
 * set-start(location)
 * -- sets the start position
 *
 * set-end(location)
 * -- sets the end position
 *
 * remove()
 * -- removes the wire
 */

module.exports = class WireView

  /* WireView(@startpos : Paper.Point, type : String) : void
   *
   * Sets up initial values of the wire
   */
  (@owner, startpos, @type = "Standard") ->
    @wire-path = new paper.Path!
    @wire-path.data.obj = this

    @selected = false
    @set-wire-type @type
    @set-start startpos

  /* item () : Item
   * return a item to be drawn
   */
  item: -> @wire-path

  /* set-line-type (type : String) : void
   *
   * Sets the line type (and consequently style) of the wire
   */
  set-wire-type: (@type) !->
    switch @type
    | "Standard" => @line-style = VS.wire-idle
    | "Selected" => @line-style = VS.wire-active
    | otherwise => @line-style = VS.other-type

    if not @selected
      @wire-path.style = @line-style

  /* set-start (location : Paper.Point) : void
   * Sets the wire start point.  Will change with fancy wires.
   */
  set-start: (startpos) !->
    @startpos = new paper.Point startpos
    @_make-wire!

  /* set-end (location : Paper.Point) : void
   * Sets the wire end point.  Will change with fancy wires.
   */
  set-end: (endpos) !->
    @endpos = new paper.Point endpos
    @_make-wire!

  /** select : void
   *
   * Mark the wire as selected. (If a selected wire is selected again,
   * it is disconnected and removed).
   */
  select: !->
    @selected = true
    @wire-path.style = VS.wire-selected

  /** deselect : void
   *
   * Mark the wire as deselected (the default state).
   */
  deselect: !->
    @selected = false
    @wire-path.style = @line-style

  /* remove () : void
   * Removes the wire from being drawn
   */
  remove: !->  @wire-path.remove-segments!

  /** wire-start : paper.Point
   *
   * The start of the wire.
   */
  wire-start: -> @startpos or @wire-path.first-curve?point1

  /** wire-end : paper.Point
   *
   * The end of the wire.
   */
  wire-end: -> @endpos or @wire-path.last-curve?point2

  /* private _make-wire : void
   *
   *  Return a group of the line to be drawn
   *
   */
  _make-wire: !->
    start = @wire-start!
    end   = @wire-end!

    return unless start and end
    @remove!

    diff = end.subtract start
    mid  = diff.multiply [0.5 0.5] .add start
    q1   = diff.multiply [0.25 0.1] .add start
    q3   = diff.multiply [0.75 0.9] .add start

    @wire-path.move-to start
    @wire-path.arc-to q1, mid
    @wire-path.arc-to q3, end

    @startpos = @endpos = undefined

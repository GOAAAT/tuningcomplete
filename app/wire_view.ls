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
  (@owner, @startpos, @type = "Standard") ->
    @wire-path = new paper.Path!
    @wire-path.data.obj = this

    @selected = false
    @set-wire-type @type

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
  set-start: (@startpos) !->
    if @endpos?
      _make-wire!

  /* set-end (location : Paper.Point) : void
   * Sets the wire end point.  Will change with fancy wires.
   */
  set-end: (@endpos) !->
    if @startpos?
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

  /* private make-wire
   *
   *  Return a group of the line to be drawn
   *
   */
  _make-wire: !->
    @wire-path.remove!

    diff = @endpos.subtract @startpos
    mid = diff.multiply [0.5 0.5] .add @startpos
    q1 = diff.multiply [0.25 0.1] .add @startpos
    q3 = diff.multiply [0.75 0.9] .add @startpos

    @wire-path.move-to @startpos
    @wire-path.arc-to q1, mid
    @wire-path.arc-to q3, @endpos

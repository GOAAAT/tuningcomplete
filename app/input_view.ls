VS = require \view_style

module.exports = class InputView

  /* InputView(type : String) : void
   * Constructor.  Type denotes the type of node, which we use a fancy case statement to find the style for.
   * Then we build the inport.  Note that NO LOCATION IS GIVEN - it is applied later by NodeView.
   */

  (@type="Standard") ->
    @size = 20
    @set-inport-style @type
    @_make!

  /* item() : Paper.Group
   * Returns the item to be drawn
   */
  item: -> @inport-path

  /* busy-port : void
   * Set port as busy and change style appropriately
   */
  busy-port: !->
    @busy = true
    @inport-path.style = @busy-style

  /* free-port : void
   * Set port ref as free and change style appropriately
   */
  free-port: !->
    @busy = false
    @inport-path.style = @free-style

  /* set-inport-type (type : String) : void
   * Sets the style of input port ref
   */
  set-inport-style: (@type) !->
    [@free-style, @busy-style] =
      VS.view-styles-for-type @type

  /* set-pos(pos : Paper.point) : void
   * set port position
   */
  set-pos: (pos) !-> @inport-path.set-position pos

  /* set-size(r : Int) : void
   * set port radius
   */
  set-size: (new-size) !->
    sf = new-size / @size
    @size = new-size
    @inport-path.scale sf

  /* private make() : void
   * makes the inport
   */
  _make: !->
    @inport-path = new paper.Path.Circle [0px 0px], @size
    @inport-path.style = @free-style

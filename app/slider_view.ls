VS = require \view_style
{min, max} = prelude

/* Public Methods
 *
 * SliderView (owner, pos)
 * - creates a view owned by node owner at position pos
 * item ()
 * - returns the group to be drawn
 * move-slider (pos)
 * - moves the slider to position pos and sets the value accordingly, then sends it
 * set-node-pos (pos)
 * - moves the node to pos
 */

module.exports = class SliderView

  /* SliderView (pos) : void
   * create view at pos
   */

  (pos, @node-size, ref) ->
    @value = 0.5
    @sticky = true
    @is-selected = false
    pos = new paper.Point pos
    @node-size = @node-size.multiply 3/4
    offset = @node-size.multiply [1/2 1/8]
    @colour = VS.slider-colours[ref]
    @_make-node pos, pos.subtract offset

  /* item() : Group
   * return the node group
   */

  item: -> @node-group

  /* select-at (pos) : bool
  */
  select-at: (pos) ->
    if @node-group.layer.data.locked
      return true
    else
      @_set-sticky !@sticky
      return false

  /* set-owner (owner) : void
  */
  set-owner: (@owner) !->

  /* private set-sticky (b) : void
   * Sets slider sticky to b
   */
  _set-sticky: (@sticky) !->
    if !@sticky
      @slider-path.stroke-color = VS.selected.stroke-color
    else
      @slider-path.style = VS.slider-path

  /* (private) _center : paper.Point
   *
   * Get the center of the slider track.
   */
  _center: -> @slider-track.position

  /* private move-slider (pos) : void
   * Move the slider to the position and return the percentage to the owner
   */
  _move-slider: (pos) ->
    {top, bottom, height} = @slider-track.bounds
    @slider-path.position.y = min bottom, (max pos.y, top)

    @value = (bottom - @slider-path.position.y) / height
    @owner.set-value @value

  /* pointer-down
   */
  pointer-down: (pos) !->
    @_move-slider pos

  /* pointer-up
  */
  pointer-up: (pos) !->
    @_move-slider (if @sticky then pos else @_center!)

  /* pointer-moved
  */
  pointer-moved: (pos) !-> @_move-slider pos

  /* set-node-pos(location : Paper.Point) : void
   * Sets the position of the node
   */
  set-node-pos: (pos) !->
    @node-group.set-position pos

  /* private make-path () : void
   * make the path, replacing the previous one
   */
  _make-node: (pos, slider-pos) !->
    # Make Slider Track
    @slider-track = new paper.Path.Line [pos.x, pos.y - (@node-size.height / 2)], [pos.x, pos.y + (@node-size.height / 2)]
    @slider-track.style = VS.slider-track

    # Make Slider
    # @slider-path = new paper.Path.Rectangle slider-pos.x, slider-pos.y, @node-size.width, @node-size.height / 8
    @slider-path = new paper.Path.Circle pos, 30
    @slider-path.style = VS.slider-path
    @slider-path.fill-color = @colour

    zero-label = new paper.PointText do
      content: 0,
      font-family: \Helvetica
      font-weight: \bold
      font-size: \18pt
    zero-label.position = [pos.x + 15, pos.y + (@node-size.height / 2)]
    zero-label.fill-color = VS.label.fill-color
    one-label = new paper.PointText do
      content: 1,
      font-family: \Helvetica
      font-weight: \bold
      font-size: \18pt
    one-label.position = [pos.x + 15, pos.y - (@node-size.height / 2)]
    one-label.fill-color = VS.label.fill-color
    half-label = new paper.PointText do
      content: 0.5,
      font-family: \Helvetica
      font-weight: \bold
      font-size: \10pt
    half-label.position = [pos.x + 15, pos.y]
    half-label.fill-color = VS.label.fill-color

    @node-group = new paper.Group [zero-label, one-label, half-label, @slider-track, @slider-path]
    @node-group.data.obj = this

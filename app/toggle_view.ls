VS = require \view_style
{min, max} = prelude

/* Public Methods
 *
 * ToggleView (owner, pos)
 * - creates a view owned by node owner at position pos
 * item ()
 * - returns the group to be drawn
 * set-node-pos (pos)
 * - moves the node to pos
 */

module.exports = class ToggleView

  /* ToggleView (pos, node-size, ref) : void
   * create view at pos
   */

  (pos, @node-size, ref) ->
    @value = 0
    @sticky = true

    if ref < 12 
      @colour = new paper.Color 1, 0, (ref/12)
    else
      @colour = new paper.Color 1, (ref-12)/12, 1-((ref-12)/12)

    # CALL THIS LAST ALWAYS
    @_make-node pos

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

  /* pointer-down
  */
  pointer-down: (pos) ->
    if !@sticky
      @_set-toggle true
    false

  /* pointer-up
  */
  pointer-up: (pos) ->
    @_set-toggle @sticky && !@value
    false

  /* pointer-moved
  */
  pointer-moved: (pos) -> false

  /* set-node-pos(location : Paper.Point) : void
   * Sets the position of the node
   */
  set-node-pos: (pos) !-> @node-group.set-position pos

  /* private set-sticky (b) : void
   * Sets toggle sticky.
   */
  _set-sticky: (@sticky) !->
    if !@sticky then
      @toggle-path.stroke-color = VS.selected.stroke-color
    else
      @toggle-path.stroke-color = VS.toggle.stroke-color

  /* private _style : Object
   *
   * Returns what the current style should be.
   */
  _style: -> 
    if @value
      VS.toggle-down 
    else 
      style = VS.toggle-up
      style.fill-color = @colour
      style

  /* private set-toggle (b) : void
   * Sets the value of the toggle
   */
  _set-toggle: (+!!@value) ->
    @toggle-path.style = @_style!
    @_set-sticky @sticky
    @owner.set-value @value

  /* private make-path () : void
   * make the path, replacing the previous one
   */
  _make-node: (pos) !->

    # Make Toggle Path
    @toggle-path = new paper.Path.Rectangle pos, @node-size.multiply 0.75
    @toggle-path.style = VS.toggle-down
    @toggle-path.fill-color = @colour

    @node-group = new paper.Group [@toggle-path]
    @node-group.data.obj = this

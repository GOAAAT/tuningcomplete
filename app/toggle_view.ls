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
    @sticky = false
    @is-selected = false
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
    
  /* set-sticky (b) : void
   * Sets toggle sticky to b
   */
  _set-sticky: (@sticky) !->
   
  /* private set-toggle (b) : void
   * Sets the value of the toggle
   */
  _set-toggle: (b) ->
    if b
      @value = 1
      @toggle-path.style = VS.toggle-down
    else
      @value = 0
      @toggle-path.style = VS.toggle-up
      
    @owner.set-value @value
  
  /* pointer-down
  */
  pointer-down: (pos) -> 
    @_selected true
    if !@sticky
      @_set-toggle true
    false
  
  /* pointer-up
  */
  pointer-up: (pos) -> 
    @_selected false
    @_set-toggle @sticky or !@value
    false
    
  /* pointer-moved
  */
  pointer-moved: (pos) -> false
    
  /* private selected (b) : void
   * Sets the path to either selected or not
   */
  _selected: (@is-selected) !->
    if @is-selected
      @toggle-path.stroke-color = VS.selected
    else
      @toggle-path.stroke-color = VS.toggle.stroke-color
      if !@sticky 
        @_set-toggle false
    
  /* set-node-pos(location : Paper.Point) : void
   * Sets the position of the node
   */
  set-node-pos: (pos) !-> @node-group.set-position pos
    
  /* private make-path () : void
   * make the path, replacing the previous one
   */
  _make-node: (pos) !->
    
    # Make Toggle Path
    @toggle-path = new paper.Path.Rectangle pos, @node-size.multiply 0.75
    @toggle-path.style = VS.toggle-up

    @node-group = new paper.Group [@toggle-path]
    @node-group.data.obj = this

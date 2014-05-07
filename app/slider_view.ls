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

const NODE_SIZE = 30

module.exports = class SliderView

  /* SliderView (owner, pos) : void
   * create view at pos
   */
   
  (@owner, @pos) ->
    @value = 0.5
    @sticky = true
    @is-selected = false
    @slider-pos = @pos
    @offset = new paper.Point NODE_SIZE, NODE_SIZE / 4
    @slider-pos = @slider-pos.subtract @offset
    @_make-node!
    
  /* item() : Group
   * return the node group
   */
   
  item: -> @node-group
   
  /* select-at (pos) : bool
  select-at: (pos) ->
    if @node-group.layer.data.locked
      return true
    else
      @_set-sticky !@sticky
      return false
    
  /* private set-sticky (b) : void
   * Sets slider sticky to b
   */
  _set-sticky: (@sticky) !->
   
  /* private move-slider (pos) : void
   * Move the slider to the position and return the percentage to the owner
   */
  _move-slider: (pos) ->
    top = @slider-track.bounds.top
    bottom = @slider-track.bounds.bottom
  
    @slider-pos.y = min bottom, (max pos.y, top)
  
    @slider-path.position = @slider-pos - [@slider-path.bounds.width / 2, @slider-path.bounds.height / 2]
    
    @value = (@slider-pos.y - top) / @slider-track.bounds.height
    @owner.set-value @value
  
  /* pointer-down
  pointer-down: (pos) !-> 
    @_selected true
    @_move-slider pos
  
  /* pointer-up
  pointer-up: (pos) !-> @_selected false
    
  /* pointer-moved
  pointer-moved: (pos) !-> @_move-slider pos
    
  /* private selected (b) : void
   * Sets the path to either selected or not
   */
  _selected: (@is-selected) !->
    if @is-selected
      @slider-path.stroke-color = VS.selected
    else
      @slider-path.stroke-color = VS.slider-path.stroke-color
      if !sticky 
        @_move-slider @slider-track.bounds.bottom
    
  /* set-node-pos(location : Paper.Point) : void
   * Sets the position of the node
   */
  set-node-pos: (@pos) !-> @node-group.set-position @pos
    
  /* private make-path () : void
   * make the path, replacing the previous one
   */
  _make-node: !->
    
    # Make Slider Track
    @slider-track = new paper.Path.Line [@pos.x, @pos.y - (NODE_SIZE * 2)], [@pos.x, @pos.y + (NODE_SIZE * 2)]
    @slider-track.style = VS.slider-track
    
    # Make Slider
    @slider-path = new paper.Path.Rectangle @slider-pos.x, @slider-pos.y, NODE_SIZE * 2, NODE_SIZE / 2
    @slider-path.style = VS.slider-path

    @node-group = new paper.Group [@slider-track, @slider-path]
    @node-group.data.obj = this

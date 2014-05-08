VS = require \view_style
{min, max} = prelude

/* Public Methods
 *
 * XYSliderView (owner, pos)
 * - creates a view owned by node owner at position pos
 * item ()
 * - returns the group to be drawn
 * move-slider (pos)
 * - moves the slider to position pos and sets the value accordingly, then sends it
 * set-node-pos (pos)
 * - moves the node to pos
 */

module.exports = class XYSliderView

  /* SliderView (pos, node-size, ref) : void
   * create view at pos
   */
   
  (pos, @node-size, ref) ->
    @xval = 0
    @yval = 0
    @is-selected = false
    console.log \NODEVIEW pos, @node-size, ref
    @_make-node pos
    
  /* item() : Group
   * return the node group
   */
   
  item: -> @node-group
   
  /* select-at (pos) : bool
  */
  select-at: (pos) ->
    return @node-group.layer.data.locked

  /* set-owner (owner) : void 
  */
  set-owner: (@owner) !->
   
  /* private move-slider (pos) : void
   * Move the slider to the position and return the percentage to the owner
   */
  _move-slider: (pos) ->
    {top, bottom} = @slider-bed.bounds

    @slider-path-c.position.x = min left, (max pos.x, right)
    @slider-path-v.position.x = @slider-path.c.position.x
    @slider-path-c.position.y = min bottom, (max pos.y, top)
    @slider-path-h.position.y = @slider-path-c.position.y
    
    @xval = (@slider-pos.x - left) / @slider-bed.bounds.width
    @yval = (@slider-pos.y - top) / @slider-bed.bounds.width
    
    @owner.set-value @xval, @yval
  
  /* pointer-down 
  */
  pointer-down: (pos) !-> 
    @_selected true
    @_move-slider pos
  
  /* pointer-up 
  */
  pointer-up: (pos) !-> @_selected false
    
  /* pointer-moved 
  */
  pointer-moved: (pos) !-> @_move-slider pos
    
  /* private selected (b) : void
   * Sets the path to either selected or not
   */
  _selected: (@is-selected) !->
    if @is-selected
      @slider-bed.stroke-color = VS.selected
    else
      @slider-bed.stroke-color = VS.slider-bed.stroke-color
    
  /* set-node-pos(location : Paper.Point) : void
   * Sets the position of the node
   */
  set-node-pos: (pos) !-> @node-group.set-position pos
    
  /* private make-path () : void
   * make the path, replacing the previous one
   */
  _make-node: (pos) !->
    
    # Make Slider Track
    @slider-bed = new paper.Path.Rectangle pos, @node-size
    @slider-bed.style = VS.xy-slider-bed
    console.log \SLIDERBED @slider-bed
    
    # Make Slider
    @slider-path-h = new paper.Path.Line (new paper.Point @slider-bed.bounds.left, pos.y), (new paper.Point @slider-bed.bounds.right, pos.y)
    @slider-path-h.style = VS.xy-slider-line
    @slider-path-v = new paper.Path.Line (new paper.Point pos.x, @slider-bed.bounds.top), (new paper.Point pos.x, @slider-bed.bounds.bottom)
    @slider-path-v.style = VS.xy-slider-line
    @slider-path-c = new paper.Path.Circle pos, 10
    @slider-path-c.style = VS.xy-slider-centre

    @node-group = new paper.Group [@slider-bed, @slider-path-h, @slider-path-v, @slider-path-c]
    @node-group.data.obj = this

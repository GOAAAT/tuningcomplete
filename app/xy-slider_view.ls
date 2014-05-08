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
    {top, bottom, left, right} = @slider-bed.bounds

    x = min right, (max pos.x, left)
    y = min bottom, (max pos.y, top)

    @slider-path-c.position = new paper.Point x, y
    @slider-path-v.position.x = @slider-path-c.position.x
    @slider-path-h.position.y = @slider-path-c.position.y
    
    @xval = (x - left) / @slider-bed.bounds.width
    @yval = 1 - ((y - top) / @slider-bed.bounds.height)
    
    @owner.set-value @xval, @yval
  
  /* pointer-down 
  */
  pointer-down: (pos) !-> 
    @_move-slider pos
    @slider-path-h.style = VS.xy-slider-line-active
    @slider-path-v.style = VS.xy-slider-line-active
  
  /* pointer-up 
  */
  pointer-up: (pos) !->
    @slider-path-h.style = VS.xy-slider-line-idle
    @slider-path-v.style = VS.xy-slider-line-idle
    
  /* pointer-moved 
  */
  pointer-moved: (pos) !-> @_move-slider pos
    
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

    # Make Slider
    _pos = new paper.Point pos
    slider-pos = _pos.add [50, 50]
    @slider-path-h = new paper.Path.Line [_pos.x, slider-pos.y], [_pos.x + @node-size.width, slider-pos.y]
    @slider-path-h.style = VS.xy-slider-line-idle
    @slider-path-v = new paper.Path.Line [slider-pos.x, _pos.y], [slider-pos.x, _pos.y + @node-size.height]
    @slider-path-v.style = VS.xy-slider-line-idle
    @slider-path-c = new paper.Path.Circle slider-pos, 10
    @slider-path-c.style = VS.xy-slider-centre

    @node-group = new paper.Group [@slider-bed, @slider-path-h, @slider-path-v, @slider-path-c]
    @node-group.data.obj = this

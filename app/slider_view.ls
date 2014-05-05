NodeView = require \node_view
VS = require \view_style
{min, max} = prelude

module.exports = class SliderView extends NodeView

  /* SliderView (owner, pos) : void
   * create view at pos
   */
   
  (@owner, @pos) ->
    super @owner, @pos, "Slider", "Numerical", []
    @value = 0.5
    
  /* move-slider (pos) : Float
   * Move the slider to the position and return the percentage
   */
   
  move-slider: (pos) ->
    
    top = @slider-track.bounds.top
    bottom = @slider-track.bounds.bottom
    
    @slider-pos.y = min bottom, (max pos.y, top)
    
    @slider-path.position = @slider-pos - [@slider-path.bounds.width / 2, @slider-path.bounds.height / 2]
      
    @value = (@slider-pos.y - top) / @slider-track.bounds.height
    @value
    
  /* set-node-pos(location : Paper.Point) : void
   * Sets the position of the node
   */
  set-node-pos: (pos) !-> @node-group.set-position pos
    
  /* private make-path () : void
   * make the path, replacing the previous one
   */
   
  _make-node: !->
    
    # Make Slider Track
    @slider-track = new paper.Path.Line [@pos.x, @pos.y - NODE_SIZE / 2], [@pos.x, @pos.y + NODE_SIZE / 2]
    @slider-track.style = VS.slider-track
    
    # Make Slider
    @slider-path = new paper.Path.Rectangle (@slider-pos - [@slider-path.bounds.width / 2, @slider-path.bounds.height / 2]), new Size (NODE_SIZE, NODE_SIZE / 4)
    @slider-path.style = VS.slider-path
    
    @node-group = new paper.Group
    @node-group.insert-children [@slider-path, @slider-track]
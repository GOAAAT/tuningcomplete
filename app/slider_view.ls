NodeView = require \node_view
VS = require \view_style

module.exports = class SliderView extends NodeView

  /* SliderView (owner, pos) : void
   * create view at pos
   */
   
  (@owner, @pos) ->
    super @owner, @pos, "Slider", "Numerical", []
    
  /* private make-path () : void
   * make the path, replacing the previous one
   */
   
  _make-node: !->
    
    # Make Slider Track
    @slider-track = new paper.Path.Line [@pos.x, @pos.y - NODE_SIZE / 2], [@pos.x, @pos.y + NODE_SIZE / 2]
    @slider-track.style = VS.slider-track
    
    # Make Slider
    
    ...
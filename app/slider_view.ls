VS = require \view_style
{min, max} = prelude

const NODE_SIZE = 30

module.exports = class SliderView

  /* SliderView (owner, pos) : void
   * create view at pos
   */
   
  (@owner, @pos) ->
    @value = 0.5
    @slider-pos = @pos
    @_make-node!
    
  /* item() : Group
   * return the node group
   */
   
  item: -> @node-group
    
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
    @slider-track = new paper.Path.Line [@pos.x, @pos.y - NODE_SIZE], [@pos.x, @pos.y + NODE_SIZE]
    @slider-track.style = VS.slider-track
    
    # Make Slider
    @slider-path = new paper.Path.Rectangle @slider-pos; new paper.Size NODE_SIZE, (NODE_SIZE / 4)
    @slider-path.style = VS.slider-path
    console.log @slider-path

    @node-group = new paper.Group
    @node-group.add-child @slider-track
    @node-group.add-child @slider-path
    @node-group.name = "SLIDER"
    console.log @node-group
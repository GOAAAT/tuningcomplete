NumericalNode = require \numerical_node
Node = require \node
VS = require \view_style
SliderView = require \slider_view

module.exports = class Slider extends NumericalNode

  /* Slider (pos) : void
   * Construct a new slider node
   */
   
  (pos) ->
    super 0, 0, pos
    @active-view.set-node-style VS.slider
    @input-view = new SliderView @, pos
    
  /* move-slider (pos) : void
   * Move the slider's position to pos.
   */
   
  move-slider: (pos) -> 
    @value = @input-view.move-slider pos
    send!
    
  /* perform-view () : Group
   * Return a group to draw
   */
   
  perform-view: -> @input-view.group!
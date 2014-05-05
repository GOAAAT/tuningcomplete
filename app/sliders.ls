Node = require \node
VS = require \view_style
SliderView = require \slider_view

module.exports = class Slider extends NumericalNode

  /* Slider (pos) : void
   * Construct a new slider node
   */
   
  (pos) ->
    super 0, 0, pos
    @active-view = new SliderView @, pos
    
  /* move-slider (pos) : void
   * Move the slider's position to pos.
   */
   
  move-slider: (pos) -> 
    @active-view.move-slider pos
    send!
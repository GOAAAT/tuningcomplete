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
    
  /* add-to-window (window) : void
   * add the node to the window
   */
  add-to-window: (win) !-> 
    super win
    win.request-input-view-for-type "Slider", @
    
  /* set-value (val) : void
   * Set the value then send it
   */
  set-value: (@value) !-> @send!
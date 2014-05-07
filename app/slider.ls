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
    @style = VS.slider
    @active-view.set-node-style @style

  /* add-to-window (window) : void
   * add the node to the window
   */
  add-to-window: (win) ->
    super win
    @input-view = win.request-input-view-for-type "Slider"
    @input-view?set-owner @
    @style.fill-color = @input-view?colour
    return @input-view?

  /* set-value (val) : void
   * Set the value then send it
   */
  set-value: (@value) !-> @send!

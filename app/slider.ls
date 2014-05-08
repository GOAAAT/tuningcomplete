NumericalNode = require \numerical_node
Node = require \node
VS = require \view_style
SliderView = require \slider_view

module.exports = class Slider extends NumericalNode
  @desc = "Produces a value in [0,1]"

  /* Slider (pos) : void
   * Construct a new slider node
   */

  (pos) ->
    super 0, 0, pos
    @active-view.set-node-style VS.slider

  /* add-to-window (window) : void
   * add the node to the window
   */
  add-to-window: (win) ->
    @input-view = win.request-input-view-for-type "Slider"
    if @input-view?
      @input-view.set-owner @
      @active-view.set-node-style do
        @active-view.node-style with
          fill-color: @input-view.colour
      return super win
    return false

  /* set-value (val) : void
   * Set the value then send it
   */
  set-value: (@value) !-> @send!

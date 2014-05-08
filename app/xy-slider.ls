NumericalNode = require \numerical_node
VS = require \view_style
SliderView = require \slider_view

module.exports = class XYSlider
  @desc = "Produces two values in [0,1]"

  /* XYSlider (pos) : void
   * Construct a new XYSlider node
   */

  (pos) ->
    @xval = 0
    @yval = 0

    @xnode = new NumericalNode 0, 0, pos
    @ynode = new NumericalNode 0, 0, pos

    @xnode.set-node-style VS.x-slider
    @ynode.set-node-style VS.y-slider

  /* add-to-window (window) : void
   * add the node to the window
   */
  add-to-window: (win) ->
    super win
    @input-view = win.request-input-view-for-type "XY-Slider"
    @input-view?set-owner @
    return @input-view?

  /* set-value (val) : void
   * Set the value then send it
   */
  set-value: (@xval, @yval) !->
    @xnode.set-value @xval
    @ynode.set-value @yval
    @xnode.send!
    @ynode.send!

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

  /* add-to-window (win, cb) : void
   * add the node to the window and passes the results to the callback
   */
  add-to-window: (win, cb) !->
    @input-view = win.request-input-view-for-type "Slider"
    if @input-view?
      @input-view.set-owner @
      @active-view.set-node-style do
        @active-view.node-style with
          fill-color: @input-view.colour

      super win, cb
    else
      cb false

  /* set-value (val) : void
   * Set the value then send it
   */
  set-value: (@value) !-> @send!

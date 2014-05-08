NumericalNode = require \numerical_node
Node = require \node
VS = require \view_style
ToggleView = require \toggle_view

module.exports = class Toggle extends NumericalNode

  /* Toggle (pos) : void
   * Construct a new toggle node
   */
  (pos) ->
    super 0, 0, pos
    @active-view.set-node-style VS.toggle
    
  /* add-to-window (window) : void
   * add the node to the window
   */
  add-to-window: (win) ->
    @input-view = win.request-input-view-for-type "Toggle"
    if @input-view?
      @input-view.set-owner @
      return super win
    return false  
    
  /* set-value (val) : void
   * Set the value then send it
   */
  set-value: (@value) !-> @send!
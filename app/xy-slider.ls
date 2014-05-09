NumericalNode = require \numerical_node
VS = require \view_style
SliderView = require \slider_view

module.exports = class XYSlider
  @desc = "Produces two values in [0,1]"

  /* XYSlider (pos) : void
   * Construct a new XYSlider node
   */

  (_pos) ->
    @xval = 0
    @yval = 0

    pos = new paper.Point _pos

    @xnode = new NumericalNode 0, 0, pos
    @ynode = new NumericalNode 0, 0, pos

    x-node-pos = pos.add [0, -5 - @xnode.view!bounds.height / 2]
    y-node-pos = pos.add [0, 5 + @ynode.view!bounds.height / 2]

    @xnode.active-view.node-group.position = x-node-pos
    @ynode.active-view.node-group.position = y-node-pos

    @xnode.active-view.set-node-style VS.x-slider
    @ynode.active-view.set-node-style VS.y-slider

    @group = new paper.Group [@xnode.view!, @ynode.view!]

    @xnode.active-view.set-label "X", \40pt
    @xnode.active-view.label.fill-color = VS.white-label
    @ynode.active-view.set-label "Y", \40pt

  /* view () : Group
   * return a group representing the nodes
   */
  view: -> @group

  /* add-to-window (window) : void
   * add the node to the window
   */
  add-to-window: (win, cb) !->
    win.insert-children [@group]
    @input-view = win.request-input-view-for-type "XY-Slider"
    @input-view?set-owner @
    cb @input-view?

  /* set-value (val) : void
   * Set the value then send it
   */
  set-value: (@xval, @yval) !->
    @xnode.value = @xval
    @ynode.value = @yval
    @xnode.send!
    @ynode.send!

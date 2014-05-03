VS = require \view_style
Input = require \input

/**  Public Methods Summary
 * (Square brackets denote optional parameters)
 *
 * NodeView([location], [type], [output-type], [inputs])
 * -- constructor method
 *
 * item() : Item
 * -- returns the item to be drawn, public
 *
 * get-input-pos(ref) : Paper.Point
 * -- returns the position of input port ref
 *
 * get-output-pos : Paper.Point
 * -- returns the position of the output port
 *
 * busy-port(ref)
 * -- marks input port ref as busy
 *
 * free-port(ref)
 * -- marks input port ref as clear
 *
 * set-node-pos(location)
 * -- sets the node position
 *
 * remove()
 * -- removes the node
 **/

const NODE_SIZE = 30
const PORT_RATIO = 4

module.exports = class NodeView

  /* NodeView(location, node-type, inputs) : void
   *
   * Instantiates instance variables
   * Default (0, 0) with 1 input and standard style
   * Inputs is a list of input_views
   */

  (@owner, pos, @node-style, @output-type = "Standard", @inputs = []) ->

    /* Set up constants:
     *
     * node-size : Int -- radius of a node
     * port-ratio : Int -- n s.t. a port has radius NODE_SIZE / n
     *
     * pos : [int, int] -- position of the node
     * outport-pos : Point -- position of the output port
     *
     * node-style : VS -- the style of the nodeNodeView
     * outport-style : VS
     *
     * inputs : [input_view] -- list of inputs to be added
     * angle : Int -- the angle the input ports are distributed by on the LHS
     */

    @set-output-type!
    @_set-input-angle!
    @_make-node pos

  /*  item() : Item
   *  returns the paper group
   */

  item: -> @node-group

  /* get-input-pos(ref : Int) : Paper.Point
   *
   * Returns position of port ref
   *
   */

  get-input-pos: (ref) ->
    _angle = ((ref+1) * @angle) + 90
    _angle = _angle * (Math.PI / 180)
    new paper.Point [Math.cos _angle; Math.sin _angle]
      .multiply NODE_SIZE
      .round!add @node-path.position

  /* get-output-pos : Paper.Point
   *
   * Returns the position of the output port
   *
   */
  get-output-pos: ->
    @node-path.position.add [
      @node-path.bounds.width / 2,
      0
    ]

  /* busy-port(ref : Int) : void
   *
   * Set port ref as busy
   *
   */
  busy-port: (ref) !-> @inputs[ref]?busy-port!

  /* free-port(ref : Int) : void
   *
   * Set port ref as free
   *
   */
  free-port: (ref) !-> @inputs[ref]?free-port!

  /* set-node-pos(location : Paper.Point) : void
   *
   * Sets the position of the node
   */
  set-node-pos: (pos) !-> @node-path.set-position pos

  /* set-node-type(type : String) : void
   * sets the node type and style
   */
  set-output-type: !->
    [ @outport-style, @busy-outport-style ] =
      VS.view-styles-for-type @output-type

  /* set-node-style: (style) : void
   * sets the node style
   */
  set-node-style: (@node-style) !->
    if not @selected
      @node-path.style = @node-style

  /* remove() : void
   *
   * removes the node
   */
  remove: !-> @node-group.remove!

  /* free and busy out () : void
   * Make the output port red.
   */

  busy-out: !-> @outport-path.style = @busy-outport-style

  free-out: !-> @outport-path.style = @outport-style

  /** select : void
   *
   * Mark the node as selected. The selected node receives subsequent pan
   * events.
   */
  select: !->
    @selected = true
    @node-path.style = VS.node-selected

  /** deselect : void
   *
   * mark the node as deselected.
   */
  deselect: !->
    @selected = false
    @node-path.style = @node-style

  /** PRIVATE METHODS **/

  /*  private set-input-angle
   *
   *  Sets the angle to offset inputs by on the node.  Basically, maths.
   *
   */
  _set-input-angle: !->
    @angle = 180 / (@inputs.length + 1)

  /*  private make-port(pos : Paper.Point, sty : VS) : Paper.Path
   *
   *  Makes a port-shaped path.  A little outdated now inputs are handled separately, but nice.
   *
   */
  _make-port: (pos, sty) ->
    path = new paper.Path.Circle pos, (NODE_SIZE / PORT_RATIO)
    path.style = sty
    path

  /*  private make-node() : Group
   *
   *  Given the location and number of inputs to the node,
   *  return a group to be drawn of the node.  Sets the specifics of the inputs.
   *
   */
  _make-node: (pos) !->

    @_set-input-angle!

    # Set up paths
    @node-path = new paper.Path.Circle pos, NODE_SIZE
    @node-path.style = @node-style

    # Add node
    @node-group = new paper.Group [ @node-path ]
    @node-group.data.obj = this

    # Add outport
    @outport-path = @_make-port @get-output-pos!, @outport-style
    @node-group.add-child @outport-path

    # Draw each individual input
    for i from 0 to (@inputs.length-1)
      @inputs[i]?input-view?set-pos (@get-input-pos i)
      @inputs[i]?input-view?set-size (NODE_SIZE / PORT_RATIO)
      @node-group.add-child @inputs[i]?input-view?item!

    # Mark node as not selected
    @deselect!

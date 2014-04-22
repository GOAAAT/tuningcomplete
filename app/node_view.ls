VS = require \view_style

/**  Public Methods Summary
 * (Square brackets denote optional parameters)
 *
 * NodeView([location], [noinputs], [style])
 * -- constructor method
 *
 * group() : Group
 * -- returns the group to be drawn, public
 *
 * get-input-pos(ref, total) : Paper.Point
 * -- returns the position of input port ref out of total
 *
 * get-output-pos : Paper.Point
 * -- returns the position of the output port
 *
 * busy-port(ref)
 * -- marks input port ref as busy
 * 
 * clear-port(ref)
 * -- marks input port ref as clear
 *
 * set-node-style(style)
 * -- sets the style of the node
 * 
 * set-outport-style(style)
 * -- sets the style of the output port
 *
 * set-node-pos(location)
 * -- sets the node position
 *
 * set-node-fill-color(col)
 * -- sets the fill colour of the node
 *
 * set-node-line-color(col)
 * -- sets the line colour of the node
 *
 * set-node-line-width(width)
 * -- sets the line width of the node
 *
 * remove()
 * -- removes the node
 **/

const NODE_SIZE = 20
const PORT_RATIO = 6

module.exports = class NodeView
  
  /* NodeView([location : Paper.Point], [style : VS], [outport-style : VS], [inputs : [input_view]]) : void
   *
   * Instantiates instance variables
   * Default (0, 0) with 1 input and standard style
   * Inputs is a list of input_views
   */
  
  (@node-pos = [0px 0px], @node-style = VS.standard, @outport-style = VS.outport, @inputs = []) ->
    /* Set up constants:
     * 
     * node-size : Int -- radius of a node
     * port-ratio : Int -- n s.t. a port has radius NODE_SIZE / n
     *
     * node-pos : Point -- position of the node
     * outport-pos : Point -- position of the output port
     *
     * node-style : VS -- the style of the nodeNodeView
     * outport-style : VS
     *
     * inputs : [input_view] -- list of inputs to be added
     * angle : Int -- the angle the input ports are distributed by on the LHS
     */
     
    # Set up the group to be returned
    @node-group = new paper.Group
    
    @outport-pos = new paper.Point @node-pos
    @outport-pos.x = @outport-pos.x + NODE_SIZE
    
    _set-input-angle!

    _make-node!
  
  /*  group() : Group
   *  returns a group to go to the canvas
   */
   
  group: ->
     @node-group
      
  /* getInputPos(ref : Int) : Paper.Point
   *
   * Returns position of port ref
   *
   */
    
  get-input-pos: (ref) ->
    _angle = ((ref+1) * @angle) + 90
    _angle *= Math.PI / 180
    
    dx = NODE_SIZE * (Math.cos _angle)
    dy = NODE_SIZE * (Math.sin _angle)
    
    ipx = @node-pos.x + dx
    ipy = @node-pos.y + dy
    
    result = new paper.Point ipx, ipy
    
    result
  
  /* getOutputPos : Paper.Point
   *
   * Returns the position of the output port
   *
   */
  
  get-output-pos: ->
    @outport-pos
    
  /* busyPort(ref : Int) : void
   *
   * Set port ref as busy
   *
   */    

  busy-port: (ref) !->
    @inputs[ref]?busy-port!

  /* clearPort(ref : Int) : void 
   *
   * Set port ref as clear
   *
   */
   
  free-port: (ref) !->
    @inputs[ref]?free-port
        
  /* set-node-style(style : VS) : void
   *
   * Sets the style of the node
   *
   */
   
  set-node-style: (@node-path.style = VS.standard) !->
    @node-style = style
    
  /* set-outport-style(style : VS) : void
   *
   * Sets the style of output port
   *
   */
   
  set-outport-style: (@outport-style = VS.outport) !->
    @outport-path.style = @outport-style

  /* set-node-pos(location : Paper.Point) : void
   *
   * Sets the position of the node
   *
   */

  set-node-pos: (@node-path.position) !->

  /* set-node-fill-color(col : Colour) :void
   * 
   * Sets the fill colour of the node
   */
    
  set-node-fill-color: (@node-path.fill-color) !->

  /* set-node-line-color(col : Colour) : void
   *
   * Sets the line colour of the node
   */
    
  set-node-line-color: (@node-path.stroke-color) !->
    
  /* set-node-line-width(width : Int) : void
   *
   * Sets the line width of the node
   */    

  set-node-line-width: (@node-path.stroke-width) !->
  
  /* remove() : void
   * removes the node
   */
   
  remove: !-> @node-group.remove-children
      
  /** PRIVATE METHODS **/
     
  /*  private set-input-angle
   *  
   *  Sets the angle to offset inputs by on the node
   *
   */
    
  _set-input-angle: !->
    @angle = 180 / (@inputs.length + 1)
  
  /*  private make-port(pos : Paper.Point, sty : VS) : Paper.Path
   *
   *  Makes a port path
   *
   */
   
  _make-port: (pos, sty) ->
    path = new paper.Path.Circle pos, (NODE_SIZE / PORT_RATIO)  
    path.style = sty
    path
    
  /*  private draw-node() : Group
   *  
   *  Given the location and number of inputs to the node,
   *  return a group to be drawn of the node.
   *
   */
  
  _draw-node: !->
    
    _set-input-angle!
    
    # Set up paths
    @node-path = new paper.Path.Circle @node-pos, NODE_SIZE
    @node-path.style = style
    
    # Add node
    @node-group.add-child @node-path
    
    @outport-path = @_make-port @outport-pos, VS.outport
    # Add outport
    @node-group.add-child @outport-path
    
    # Draw each individual input
    i = 0
    for i from 0 to @inputs.length
      @inputs[i]?set-pos @get-input-pos i
      @inputs[i]?set-size (NODE_SIZE / PORT_RATIO)
      @node-group.add-child @inputs[i]
  
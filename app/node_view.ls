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
 * set-port-style(style, port)
 * -- sets the style of a given node type ("outport", "inport_busy", "inport_clear")
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
 **/

const NODE_SIZE = 20
const PORT_RATIO = 6

module.exports = class NodeView
  
  /* Node_View([location : Paper.Point], [noinputs : int], [style : VS]) : void
   *
   * Instantiates instance variables
   * Default (0, 0) with 1 input and standard style
   *
   */
  
  (@node-pos = [0px 0px], @noinputs = 1, @node-style = VS.standard) ->
    /* Set up constants:
     * 
     * node-size : Int -- radius of a node
     * port-ratio : Int -- n s.t. a port has radius NODE_SIZE / n
     *
     * node-pos : Point -- position of the node
     * outport-pos : Point -- position of the output port
     *
     * node-style : VS -- the style of the nodeNodeView
     * inport-busy-style : VS
     * inport-clear-style : VS
     * outpor-style : VS
     *
     * noinputs : Int -- number of inputs to this node
     * inputs : List[Int] -- list of busy (true) and clear (false) for nodes
     * angle : Int -- the angle the input ports are distributed by on the LHS
     */
     
    # Set up the group to be returned
    @node-group = new Group
    
    @outport-pos = new paper.Point @node-pos
    @outport-pos.x = @outport-pos.x + NODE_SIZE
    
    @outport-style     = VS.outport
    @inport-busy-style  = VS.inport-busy
    @inport-clear-style = VS.inport-clear
    
    @inputs = []
    _set-input-angle!
    
    /** Set up input list of true/false (busy/clear) **/
    i = 0
    while i < @noinputs
       @inputs = [false] * @inputs
       i++

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
    @inputs[ref] = true
    @inports[ref].style = @inport-busy-style

  /* clearPort(ref : Int) : void 
   *
   * Set port ref as clear
   *
   */
   
  clear-port: (ref) !->
    @inputs[ref] = false
    @inports[ref].style = @inport-clear-style
        
  /* set-node-style(style : VS) : void
   *
   * Sets the style of the node
   *
   */
   
  set-node-style: (@node-path.style = VS.standard) !->
    @node-style = style
    
  /* set-port-style(style : VS, port : String) : void
   *
   * Sets the style of a port style
   *
   *  "outport", "inport_busy", "inport_clear" only accepted ports
   *
   */
   
  set-port-style: (style = VS.standard, port = "N/A") !->
    switch port
    | "outport"     => 
      @outport-path.style = style
      @outport-style = style
    | "inport-busy" => 
      @inport-busy-style = style
    | "inport-clear" => 
      @inport-clear-style = style
    for i from 0 to @noinputs
      if @inputs[i]
        @inports[i].style = @inport-busy-style
      else
        @inports[i].style = @inport-clear-style
        
    # Not as clean as it should be but I was getting too many errors from trying to neaten it

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
      
  /** PRIVATE METHODS **/
     
  /*  private set-input-angle
   *  
   *  Sets the angle to offset inputs by on the node
   *
   */
    
  _set-input-angle: !->
    @angle = 180 / (@noinputs + 1)
  
  /*  private make-port(pos : Paper.Point, sty : VS) : Paper.Path
   *
   *  Makes a port path
   *
   */
   
  _make-port: (pos, sty) ->
    path = new paper.Path.Circle pos, (NODE_SIZE / PORT_RATIO)  
    path.style = sty
    path
    
  /*  private DrawNode() : Group
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
    
    @inports = []
    # Draw each individual input
    i = 0

    for i from 0 to @noinputs
        @inports[i] = @_make-port @get-input-post i,
          @inputs[i] ? VS.inport-busy : VS.inport-clear     
        @node-group.add-child inports[i]
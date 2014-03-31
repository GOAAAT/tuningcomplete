VS = require \view_style

/**  Public Methods Summary
 * (Square brackets denote optional parameters)
 *
 *
 * Node_View([location], [noinputs], [style])
 * -- constructor method
 *
 * draw-node(location, noinputs) : Group
 * -- draws a node at specified location with specified number of inputs
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
 * redraw : Group
 * -- redraws the node without resetting anything
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

export class Node_View
  
  /* Node_View([location : Paper.Point], [noinputs : int], [style : VS]) : void
   *
   * Instantiates instance variables
   * Default (0, 0) with 1 input and standard style
   *
   */
  
  (location = new Point 0 0, noinputs = 1, style = VS.standard) ->
    /* Set up constants:
     * 
     * nodeSize : Int -- radius of a node
     * portRatio : Int -- n s.t. a port has radius nodeSize / n
     *
     * nodePos : Point -- position of the node
     * outportPos : Point -- position of the output port
     *
     * nodeStyle : VS -- the style of the node
     * inportBusyStyle : VS
     * inportClearStyle : VS
     * outportStyle : VS
     *
     * noinputs : Int -- number of inputs to this node
     * inputs : List[Int] -- list of busy (true) and clear (false) for nodes
     * angle : Int -- the angle the input ports are distributed by on the LHS
     */
    
    @nodeSize     = 20
    @portRatio    = 6
    
    @nodePos      = location.clone
    @outportPos   = new paper.Point 0 0
    
    @nodeStyle    = style
        
    @outportStyle     = VS.outport
    @inportBusyStyle  = VS.inport_busy
    @inportClearStyle = VS.inport_clear
    
    @noinputs     = noinputs
    @inputs       = []
    @angle        = _set-input-angle
    
    /** Set up input list of true/false (busy/clear) **/
    i = 0
    while i < @noinputs
       @inputs = [false] ++ @inputs
       i++
    
  /*  DrawNode(location : Paper.Point, noinputs : Int) : Group
   *  
   *  Given the location and number of inputs to the node,
   *  return a group to be drawn of the node.
   *
   */
  
  draw-node: (location, noinputs) ->
  
    # Set up the group to be returned
    result = new Group
  
    # Set up position info
    @nodePos = location

    @outportPos = new Point @nodePos
    @outportPos.x = outportPos.x + @nodeSize
    
    _set-input-angle
    
    # Set up paths
    nodePath = new Path.Circle @nodePos @nodeSize
    nodePath.style = style
    
    # Add node
    result.addChild nodePath
    
    # Add outport
    result.addChild (_make-port @outportPos VS.outport)
    
    # Draw each individual input
    i = 0

    while i < @noinputs
      if @inputs[i]
        result.addChild (_make-port (get-input-pos i) VS.inport_busy)
      else
        result.addChild (_make-port (get-input-pos i) VS.inport_clear)
    
    # Return the group
    result
  
  /* getInputPos(ref : Int) : Paper.Point
   *
   * Returns position of port ref
   *
   */
    
  get-input-pos: (ref) ->
    _angle = ((ref+1) * @angle) + 90
    _angle = _angle * (Math.PI / 180)
    
    dx = @nodeSize * (Math.cos _angle)
    dy = @nodeSize * (Math.sin _angle)
    
    ipx = @nodePos.x + dx
    ipy = @nodePos.y + dy
    
    result = new Point ipx ipy
    
    result
  
  /* getOutputPos : Paper.Point
   *
   * Returns the position of the output port
   *
   */
  
  get-output-pos: ->
    @outportPos
    
  /* busyPort(ref : Int) : void
   *
   * Set port ref as busy
   *
   */    

  busy-port: (ref) !->
    @inputs[ref] = true
    redraw

  /* clearPort(ref : Int) : void 
   *
   * Set port ref as clear
   *
   */
   
  clear-port: (ref) !->
    @inputs[ref] = false
    redraw
    
  /* redraw : Group
   * 
   * Calls draw-node with parameters the same
   *
   */
    
  redraw ->
    draw-node @nodePos @noinputs
    
  /* set-node-style(style : VS) : void
   *
   * Sets the style of the node
   *
   */
   
  set-node-style: (style = VS.standard) !->
    @nodeStyle = style
    redraw
    
  /* set-port-style(style : VS, port : String) : void
   *
   * Sets the style of a port style
   *
   *  "outport", "inport_busy", "inport_clear" only accepted ports
   *
   */
   
  set-port-style: (style = VS.standard, port = "N/A") !->
    if port == "outport" 
      @outportStyle = style
    else if port == "inport_busy"
      @inportBusyStyle = style
    else if port == "inport_clear"
      @inportClearStyle = style
    redraw

  /* set-node-pos(location : Paper.Point) : void
   *
   * Sets the position of the node
   *
   */
   
  set-node-pos: (location) !->
    @nodePos = location

  /* set-node-fill-color(col : Colour) :void
   * 
   * Sets the fill colour of the node
   */
    
  set-node-fill-color: (col) !->
    @nodeStyle.fillColor = col

  /* set-node-line-color(col : Colour) : void
   *
   * Sets the line colour of the node
   */
    
  set-node-line-color: (col) !->
    @nodeStyle.strokeColor = col
    
  /* set-node-line-width(width : Int) : void
   *
   * Sets the line width of the node
   */    

  set-node-line-width: (width) !->
    @nodeStyle.strokeWidth = width
      
  /** PRIVATE METHODS **/
     
  /*  private set-input-angle
   *  
   *  Sets the angle to offset inputs by on the node
   *
   */
    
  _set-input-angle !->
    @angle = 180 / (@noinputs + 1)
  
  /*  private make-port(pos : Paper.Point, sty : VS) : Paper.Path
   *
   *  Makes a port path
   *
   */
   
  _make-port: (pos, sty) ->
    path = new Path.Circle pos (@nodeSize / @portRatio)  
    path.style = sty
    path

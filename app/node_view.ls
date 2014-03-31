VS = require \view_style

export class Node_View
  
  /* Node_View(location : Paper.Point, noinputs : int) : void
   *
   * Instantiates instance variables
   * Default (0, 0) with 1 input 
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
        result.addChild (_make-port (_get-input-pos i) VS.inport_busy)
      else
        result.addChild (_make-port (_get-input-pos i) VS.inport_clear)
      
    result
  
  /* getInputPos(ref : Int, total : Int) : Paper.Point
   *
   * Returns position of port 'ref' if there are 'total' input ports
   *
   *
   * Private version exists for interior use
   */
    
  get-input-pos: (ref, total) ->
    _get-input-pos ref
  
  
  
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

  /* clearPort(ref : Int) : void 
   *
   * Set port ref as clear
   *
   */
   
  clear-port: (ref) !->
    @inputs[ref] = false
    
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
    
  _get-input-pos: (ref) ->
    _angle = ((ref+1) * @angle) + 90
    _angle = _angle * (Math.PI / 180)
    dx = @nodeSize * (Math.cos _angle)
    dy = @nodeSize * (Math.sin _angle)
    ipx = @nodePos.x + dx
    ipy = @nodePos.y + dy
    result = new Point ipx ipy
    result
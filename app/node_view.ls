Node = require \node

export class Node_View
  
  /* Node_View(location : Paper.Point, noinputs : int) : void
   *
   * Instantiates instance variables
   * Default (0, 0) with 1 input 
   *
   */
  
  (location = new Point 0 0, noinputs = 1) ->
    /* Set up constants:
     * nodeSize : Int -- radius of a node
     * nodePos : Point -- position of the node
     * outportPos : Point -- position of the output port
     * fillColor : Color
     * lineColor : Color
     * noinputs : Int -- number of inputs to this node
     * inputs : List[Int] -- list of busy (true) and clear (false) for nodes
     */
    
    nodeSize = 20
    
    nodeFillColor = '#111111'
    outportFillColor = '#111111'
    inportBusyFillColor = '#00ff00'
    inportClearFillColor = '#ff0000'
    lineColor = '#000000'
    
    nodePos = location.clone
    outportPos = new paper.Point 0 0
    
    noinputs = noinputs
    inputs = []
    angle = _set-input-angle
    
    # Set up input list of true/false (busy/clear)
    i = 0
    while i < noinputs
       inputs = [false] ++ inputs
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
  
    # Set up preliminary info
    nodePos = location
    
    outportPos = new Point nodePos
    outportPos.x = outportPos.x + nodeSize
    
    # Set up paths
    nodePath = new Path.Circle nodePos nodeSize
    nodePath.strokeColor = lineColor
    nodePath.nodeFillColor = fillColor
    result.addChild nodePath
    
    outportPath = new Path.Circle outportPos (nodeSize / 4)
    outportPath.strokeColor = lineColor
    outportPath.fillColor = outportFillColor
    result.addChild outportPath
    
    _set-input-angle
    
    # Draw each individual input
    i = 0
    while i < noinputs
      inportPath = new Path.Circle (_get-input-pos i) (nodeSize / 4)
      inportPath.strokeColor = lineColor
      if inputs[i]
        inportPath.fillColor = inportBusyFillColor
      else
        inportPath.fillColor = inportClearFillColor
      result.addChild inportPath
      
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
  
  _get-input-pos: (ref) ->
    _angle = (ref+1) * angle
    dx = nodeSize * (Math.cos _angle)
    dx = dx * -1
    dy = nodeSize * (Math.sin _angle)
    dy = dy * -1
    ipx = nodePos.x + dx
    ipy = nodePos.y + dy
    result = new Point ipx ipy
    result
  
  /* getOutputPos : Paper.Point
   *
   * Returns the position of the output port
   *
   */
  
  get-output-pos: ->
    outportPos
  	
  /* busyPort(ref : Int) : void
   *
   * Set port ref as busy
   *
   */  	

  busy-port: (ref) !->
    inputs[ref] = true

  /* clearPort(ref : Int) : void 
   *
   * Set port ref as clear
   *
   */
   
  clear-port: (ref) !->
    inputs[ref] = false
    
  _set-input-angle !->
    angle = 180 / @noinputs
  
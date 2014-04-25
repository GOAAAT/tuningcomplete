VS = require \view_style
Input = require \input

/**  Public Methods Summary
 * (Square brackets denote optional parameters)
 *
 * NodeView([location], [type], [output-type], [inputs])
 * -- constructor method
 *
 * group() : Group
 * -- returns the group to be drawn, public
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
 * set-node-type(type)
 * -- sets the type of the node
 * 
 * set-outport-type(type)
 * -- sets the type of the output port
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
  
  /* NodeView([location : Paper.Point], [type : string], [output-type : String], [inputs : [InputView]]) : void
   *
   * Instantiates instance variables
   * Default (0, 0) with 1 input and standard style
   * Inputs is a list of input_views
   */

  (pos = [100, 100], @node-type = "Standard", @inputs = []) ->

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
    
    @node-pos = new paper.Point pos
    
    switch @node-type
    | "Maths" => 
        @node-style = VS.maths
        @output-type = VS.numerical-free
    | "Oscillator" => 
        @node-style = VS.oscillator
        @output-type = VS.audio-free
    | "Instrument" => 
        @node-style = VS.instrument
        @output-type = VS.audio-free
    | otherwise => 
        @node-style = VS.standard
        @output-type = VS.other-type
        
    @outport-pos = new paper.Point @node-pos
    @outport-pos.x = @outport-pos.x + NODE_SIZE
    
    switch @output-type
    | "Numerical" => @outport-style = VS.numerical-out
    | "Audio" => @outport-style = VS.audio-out
    | otherwise => @outport-style = VS.standard-out
    
    @_set-input-angle!

    @_make-node!
  
  /*  group() : Group
   *  returns the paper group
   */
   
  group: -> @node-group
      
  /* get-input-pos(ref : Int) : Paper.Point
   *
   * Returns position of port ref
   *
   */
    
  get-input-pos: (ref) ->
    _angle = ((ref+1) * @angle) + 90
    _angle *= Math.PI / 180
    
    dx = Math.round (NODE_SIZE * (Math.cos _angle))
    dy = Math.round (NODE_SIZE * (Math.sin _angle))
    
    ipx = @node-pos.x + dx
    ipy = @node-pos.y + dy
    
    result = new paper.Point ipx, ipy
    
    result
    
  
  /* get-output-pos : Paper.Point
   *
   * Returns the position of the output port
   *
   */
  get-output-pos: -> @outport-pos
    
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

  /* set-node-fill-color(col : Colour) :void
   * 
   * Sets the fill colour of the node
   */
  remove: !-> @node-group.remove!
      
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
  _make-node: !->
    
    @_set-input-angle!
    
    # Set up paths
    @node-path = new paper.Path.Circle @node-pos, NODE_SIZE
    @node-path.style = @node-style
    
    # Add node
    @node-group = new paper.Group [ @node-path ]
    
    @outport-path = @_make-port @outport-pos, @outport-style
    # Add outport
    @node-group.add-child @outport-path
    
    # Draw each individual input
    for i from 0 to (@inputs.length-1)
      @inputs[i]?input-view?set-pos (@get-input-pos i)
      @inputs[i]?input-view?set-size (NODE_SIZE / PORT_RATIO)
      @node-group.add-child @inputs[i]?input-view?item!

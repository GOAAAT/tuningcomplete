VS = require \view_style

module.exports = class InputView
  
  /* InputView(type : String) : void
   *
   * Constructor.  Type denotes the type of node, which we use a fancy case statement to find the style for.
   * Then we build the inport.  Note that NO LOCATION IS GIVEN - it is applied later by NodeView.
   *
   */
  
  (@type="Standard") ->
    
    switch @type
    | "Audio"     => 
      @free-style = VS.audio-free
      @busy-style = VS.audio-busy
    | "Numerical" =>
      @free-style = VS.numerical-free
      @busy-style = VS.numerical-busy
    | "Standard"  =>
      @free-style = VS.standard-free
      @busy-style = VS.standard-busy
      
    @make!
  
  /* item() : Paper.Group
   * 
   * Returns the item to be drawn
   *
   */
  
  item: -> @inport-path
  
  /* busyPort(ref : Int) : void
   *
   * Set port ref as busy and change style appropriately
   *
   */    

  busy-port: (ref) !->
    if !@busy 
      @busy = true
      @inport-path.style = @busy-style

  /* freePort(ref : Int) : void 
   *
   * Set port ref as free and change style appropriately
   *
   */
   
  free-port: (ref) !->
    if busy
      @busy = false
      @inport-path.style = @free-style
      
  /* private make() : void
   *
   * makes the inport
   */
   
  _make: !->
    @inport-path = new paper.Path.Circle [0px, 0px], 20
    @inport-path.style = @free-style
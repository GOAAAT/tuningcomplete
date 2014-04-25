VS = require \view_style
Colour = require \color

/** Public Methods Summary 
 *
 * WireView(start, type)
 * -- sets up initial values of the wire
 *
 * item()
 * -- returns the wire item
 *
 * set-wire-type(type)
 * -- sets the wire type and style
 *
 * set-start(location)
 * -- sets the start position
 *
 * set-end(location)
 * -- sets the end position
 *
 * remove()
 * -- removes the wire
 */

module.exports = class WireView

  /* WireView(start : Paper.Point, type : String) : void
   *
   * Sets up initial values of the wire
   */
  (@startpos, @type = "Standard") ->
    /* Set up constants:
     * startpos : Paper.Point
     * type : String
     */
    
    @wire-path = new paper.Path
    @wire-path.add @startpos
    
    @set-wire-type @type
    
  /* item () : Item
   * return a item to be drawn
   */
  item: -> @wire-path
      
  /* set-line-type (type : String) : void
   *
   * Sets the line type (and consequently style) of the wire
   */
  set-line-type: (@type) !->
    switch @type
    | "Standard" => @wire-path.style = VS.wire-idle
    | otherwise => @wire-path.style = VS.other-type
    @wire-path.style = @line-style
    
  /* set-start (location : Paper.Point) : void
   * Sets the wire start point.  Will change with fancy wires.
   */
  set-start: (@startpos) !-> 
    @wire-path.remove-segment 0
    @wire-path.insert-segment 0, @startpos
    
  /* set-end (location : Paper.Point) : void
   * Sets the wire end point.  Will change with fancy wires.
   */
  set-end: (@endpos) !->
    @wire-path.remove-segment 1
    @wire-path.insert-segment 1, @endpos
  
  /* remove () : void
   * Removes the wire from being drawn
   */
  remove: !->  @wire-path.remove-segment 1
    
  /* private make-wire 
   * 
   *  Return a group of the line to be drawn
   *
   */  
  _make-wire: !->
    
    # Fancy wires to come in the far off future!
    
    @wire-path = new paper.Path @startpos, @endpos
    @wire-path.style = @line-style

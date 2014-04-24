VS = require \view_style

/** Public Methods Summary 
 *
 * WireView(start, type)
 * -- sets up initial values of the wire
 *
 * set-line-style(style)
 * -- sets the line style
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
   *
   */
  
  (@startpos, @type = "Standard") ->
    /* Set up constants:
     * 
     * lineStyle : VS -- the style of the line
     * 
     * startpos : Paper.Point
     */
     
    switch @type
    | "Standard" => @line-style = VS.wire-idle
    
    @wire-path = new paper.Path
    @wire-path.add @startpos
    
  /* group () : Group
   * return a group to be drawn
   */
    
  group: ->
    @wire-path
      
  /* set-line-type (type : String) : void
   *
   * Sets the line type (and consequently style) of the wire
   *
   */
   
  set-line-type: (@type) !->
    switch type
    | "Standard" => @line-style = VS.wire-idle
    @wire-path.style = @line-style
    
  /* set-start (location : Paper.Point) : void
   *
   * Sets the wire start point
   *
   */
   
  set-start: (@startpos) !->
    @_make-wire!
    
  /* set-end (location : Paper.Point) : void
   *
   * Sets the wire end point
   *
   */

  set-end: (@endpos) !-> 
    @_make-wire!
  
  /* remove () : void
   *
   * Removes the wire from being drawn
   */
   
  remove: !-> @wire-path.remove
  
  /* private make-wire 
   * 
   *  Return a group of the line to be drawn
   *
   */  
  
  _make-wire: !->
    
    # Fancy wires to come in the far off future!
    
    @wire-path = new paper.Path @startpos, @endpos
    @wire-path.style = @line-style

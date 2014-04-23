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
    console.log @line-style
    
    @wire-path = new paper.Path
    
  /* group () : Group
   * return a group to be drawn
   */
    
  group: ->
    @wire-path
      
  /* set-line-style (style : VS) : void
   *
   * Sets the line style of the wire
   *
   */
   
  set-line-style: (@type) !->
    switch type
    | "Standard" => @line-style = VS.wire-idle
    @wire-path.style = @line-style
    
  /* set-start (location : Paper.Point) : void
   *
   * Sets the wire start point
   *
   */
   
  set-start: (@startpos) !->
    
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
    
    # Fancy wires to come!
    
    @wire-path = new paper.Path @startpos, @endpos
    @wire-path.stroke-color = \#FFF

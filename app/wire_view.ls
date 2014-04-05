VS = require \view_style

/** Public Methods Summary 
 *
 * WireView([start], [end], [style])
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

  /* WireView(start : Paper.Point, end : Paper.Point, style : VS) : void
   *
   * Sets up initial values of the wire
   *
   */
  
  (@startpos = [0px 0px], @endpos = [0px 0px], @line-style = VS.line_idle) ->
    /* Set up constants:
     * 
     * lineStyle : VS -- the style of the line
     * 
     * startpos : Paper.Point
     * endpos : Paper.Point
     */
     
    @wire-group = new paper.Group
    
    _make-wire!
    
  /* group () : Group
   * return a group to be drawn
   */
    
  group: ->
    @wire-group
      
  /* set-line-style (style : VS) : void
   *
   * Sets the line style of the wire
   *
   */
   
  set-line-style: (@line-style) !->
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
  
  /* remove () : void
   *
   * Removes the wire from being drawn
   */
   
  remove: !-> @wire-group.remove-children
  
  /* private make-wire 
   * 
   *  Return a group of the line to be drawn
   *
   */  
  
  _make-wire: !->
    
    # Fancy wires to follow in the future!
    
    @wire-path = new paper.Path.Line start, end
    @wire-path.style = @line-style
    
    @wire-group.add-child @wire-path
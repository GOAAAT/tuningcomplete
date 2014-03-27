
VS = require \view_style

/** Public Methods Summary 
 *
 * Wire_View([start], [end], [style])
 * -- sets up initial values of the wire
 *
 * draw-wire(startpos, endpos) : Group
 * -- returns a group for drawing representing the wire
 *
 * redraw()
 * -- redraws the wire
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
 */

export class Wire_View

  /* Wire_View(start : Paper.Point, end : Paper.Point, style : VS) : void
   *
   * Sets up initial values of the wire
   *
   */
  
  (start = new Point 0 0, end = new Point 0 0, style = VS.line_idle) ->
    /* Set up constants:
     * 
     * lineStyle : VS -- the style of the line
     * 
     * startpos : Paper.Point
     * endpos : Paper.Point
     */
     
    @lineStyle = style
    
    @startpos = start
    @endpos = end
    
  /* draw-wire (startpos : Paper.Point, endpos : Paper.Point) : Group
   * 
   *  Return a group of the line to be drawn
   *
   */  
  
  draw-wire: (start, end) ->
    
    result = new Group
    
    @startpos = start
    @endpos = end
    
    wirePath = new Path.Line start end
    wirePath.style = @lineStyle
    
    result.addChild wirePath
    
    result
  
  /* redraw : void
   *
   * Redraws the line exactly how it was before
   *
   */
   
  redraw !->
    draw-wire @startpos @endpos
    
  /* set-line-style (style : VS) : void
   *
   * Sets the line style of the wire
   *
   */
   
  set-line-style: (style) !->
    @lineStyle = style
    
  /* set-start (location : Paper.Point) : void
   *
   * Sets the wire start point
   *
   */
   
  set-start: (location) !->
    @startpos = location
    
  /* set-end (location : Paper.Point) : void
   *
   * Sets the wire end point
   *
   */
   
  set-end: (location) !->
    @endpos = location

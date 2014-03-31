VS = require \view_style

export class Wire_View
  
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
    
  /* draw-wire (startpos : Paper.Point, endpos : Paper.Point) : void
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
  
  
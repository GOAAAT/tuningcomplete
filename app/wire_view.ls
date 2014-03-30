Colour = require \color

export class Wire_View
  
  (start = new Point 0 0, end = new Point 0 0) ->
    /* Set up constants:
     * 
     * lineColor : Color -- colour of the line
     *
     */
     
    lineColor = Colour.black
    lineWidth = 5
    
    startpos = start
    endpos = end
    
  /* draw-wire (startpos : Paper.Point, endpos : Paper.Point) : void
   * 
   *  Return a group of the line to be drawn
   *
   */  
  
  draw-wire: (start, end) ->
    
    result = new Group
    
    startpos = start
    endpos = end
    
    wirePath = new Path.Line start end
    wirePath.strokeColor = lineColor
    wirePath.strokeWidth = lineWidth
    
    result.addChild wirePath
    
    result
  
  
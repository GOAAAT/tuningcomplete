Wire = require \wire

export class Wire_View
  
  ->
    /* Set up constants:
     * 
     * lineColor : Color -- colour of the line
     *
     */
     
    lineColor = '#000000';
    
  /* draw-wire (startpos : Paper.Point, endpos : Paper.Point) : void
   * 
   *  wirePath : Path.Line -- The line for the wire
   *  
   *  Presumably this needs a canvas to draw on?
   *
   */  
  
  draw-wire: (startpos, endpos) ->
    
    wirePath = new Path.Line startpos endpos
    wirePath.strokeColor = 'black'
    
    return new Group([wirePath])
  
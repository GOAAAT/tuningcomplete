Node = require \node

export class Node_View
  ->
    /* Set up constants:
     * nodeSize : Int -- radius of a node
     * fillColor : Color
     * lineColor : Color
     */
    
    @nodeSize = 20
    @fillColor = '#ff0000';
    @lineColor = '#000000';
    
    
  /*  DrawNode(location : Paper.Point) : void
   *  nodePath : Path.Circle   -- The node itself
   *  
   *  This presumably needs passing to a canvas somewhere?
   *
   */
  
  draw-node: (location) !->
    
    nodePath = new Path.Circle location nodeSize
    nodePath.strokeColor = lineColor
    nodePath.fillColor = fillColor
    
    return new Group([nodePath])
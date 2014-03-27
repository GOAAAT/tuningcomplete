Node = require \node

export class Node_View

	->
		/* Set up constants:
		 * nodeSize : Int -- radius of a node
		 * fillColor : Color
		 * lineColor : Color
		 */
	
		@nodeSize = 20
		@fillColor = new Color 1 0 0
		@lineColor = new Color 0 0 0
	
	
	/*	DrawNode(location : Paper.Point) : void
	 *	nodePath : Path.Circle 	-- The node itself
	 *	
	 *	This presumably needs passing to a canvas somewhere?
	 *
	 */
	
	draw-node: (location) !->
		
		nodePath = new Path.Circle location nodeSize
		nodePath.strokeColor = lineColor
		nodePath.fillColor = fillColor
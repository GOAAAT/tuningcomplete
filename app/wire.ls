/**
* Wires connect nodes, transferring data from an 'origin' to a 'destination' 
*/

export class Wire
  (node) ->
    origin = node
    active-view.set-start(origin.location)

  var dest
  var dest-port
  active-view = new Wire_View # TODO need to specify (start, end, style)

  /** origin-node: node
  * Returns node which is putting data onto wire
  *  TODO: not convinced this is needed?
  */
  origin-node: -> origin
  
  /** set-dest: void
  * node: Node
  * port: int
  * Set where the wire is going to.
  */  
  set-dest: (node, port) !->
    dest = node
    dest-port = port
    active-view.set-end(dest.location)
  
  /** get-dest-port: int
  * Returns port that wire is connected to at destination
  * TODO: not convinced this needed?
  */
  get-dest-port: -> dest-port
  
  /** delete: void
  * delete the wire
  * The destination node is (at present) told of the disconnection by the origin node.
  */
  delete: !-> origin.disconnect(@)
  
  /** redraw: void
  * Informs the wire that it should redraw its end-point
  *  (called when a node is moved, so the wires can move with it)
  */
  redraw: !-> active-view.redraw


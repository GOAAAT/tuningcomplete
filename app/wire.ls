/**
* Wires connect nodes, transferring data from an 'origin' to a 'destination' 
*/

WireView = require \WireView

/* Wire(node : Node) : void
 *
 * Constructor
 */

module.exports = class Wire
  (@origin) ->
  
  /* view () : Group
   *
   * Return a group to draw on canvas
   */
  view: -> @active-view?group!
  
  /** origin-node: node
  * Returns node which is putting data onto wire
  *
  */
  origin-node: -> @origin
  
  /** set-dest (node : Node, port : Int): void
  * i.e. connect
  * node: Node
  * port: int
  * Set where the wire is going to.
  */  
  set-dest: (@dest, @dest-port) !->
    @active-view = new NodeView @origin.location!, @dest.get-location!
  
  /** get-dest-port: int
  * Returns port that wire is connected to at destination
  * 
  */
  get-dest-port: -> @dest-port
  
  /** delete-wire: void
  * delete the wire
  * The destination node is (at present) told of the disconnection by the origin node.
  */
  delete-wire: !-> @origin.disconnect! @
  
  /** redraw: void
  * Informs the wire that it should redraw its end-point
  *  (called when a node is moved, so the wires can move with it)
  */
  redraw: !-> @active-view.set-end! @dest.get-location!


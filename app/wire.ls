/**
* Wires connect nodes, transferring data from an 'origin' to a 'destination' 
*/

<<<<<<< HEAD
WireView = require \wire_view
Node = require \node
=======
WireView = require \WireView
>>>>>>> Controller: Wire: Made changes from pull request comments

/* Wire(node : Node) : void
 * Constructor
 */
<<<<<<< HEAD
=======

module.exports = class Wire
  (@origin) ->
<<<<<<< HEAD
>>>>>>> Controller: Wire: Made changes from pull request comments

module.exports = class Wire
  (@origin) ->
=======
>>>>>>> Controller: Wire: Added View function
  
  /* view () : Group
   * Return a group to draw on canvas
   */
  view: -> @active-view?group!
  
  /** origin-node: node
  * Returns node which is putting data onto wire
  */
  origin-node: -> @origin
  
  /** set-dest (node : Node, port : Int): void
  * i.e. connect
  * node: Node
  * port: int
  * Set where the wire is going to - should be getting get-input-pos??
  */  
  set-dest: (@dest, @dest-port) !->
<<<<<<< HEAD
    @active-view = new NodeView @origin?location!, @dest?get-location!
=======
    @active-view = new NodeView @origin.location!, @dest.get-location!
>>>>>>> Controller: Wire: Made changes from pull request comments
  
  /** get-dest-port: int
  * Returns port that wire is connected to at destination
  */
  get-dest-port: -> @dest-port
  
<<<<<<< HEAD
  /** remove: void
  * delete the wire
  * The destination node is (at present) told of the disconnection by the origin node.
  */
  remove: !-> @origin?disconnect @
=======
  /** delete-wire: void
  * delete the wire
  * The destination node is (at present) told of the disconnection by the origin node.
  */
  delete-wire: !-> @origin.disconnect! @
>>>>>>> Controller: Wire: Made changes from pull request comments
  
  /** redraw: void
  * Informs the wire that it should redraw its end-point
  *  (called when a node is moved, so the wires can move with it)
  */
<<<<<<< HEAD
  redraw: !-> @active-view?set-end! @dest?get-location!
=======
  redraw: !-> @active-view.set-end! @dest.get-location!
>>>>>>> Controller: Wire: Made changes from pull request comments

  /** set-end (location : paper.Point) : void
   * Sets the end of the wire to a position on the canvas
   */
   
  set-end: (pos) !->
    @active-view?set-end! pos

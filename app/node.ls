  /**
  * REQUIREMENT
  *
  * Connect and disconnect should always
  * be called on the receiving node
  *
  * Location and total-inputs should always be set on initialising
  * a node
  */

export class Node
  ->

    @total-inputs
    @location

    @active-inputs = 0
    @send-list = []
    @receiving-wires = []
    for i from 1 to total-inputs 
      @receiving-wires = [null] ++ @receiving-wires
    @active-view = new Node_View

    /** view : Group
    * 
    * Requests node_view draws the node again
    * and instructs all Wires to ask to be redrawn
    */
    view: ->
      for wire in @receiving-wires
       if wire ~= null then wire?redraw
      @active-view?draw-node location, total-inputs


export class Input
  ->

    /** get-input-pos : paper.Point
    *  ref : int
    *
    * Requests the position of port 'ref' from node_view
    */
    get-input-pos: (ref) ->
      @active-view?get-input-pos ref
  
    /** register-input : void
    *  ref : int
    * wire : Wire
    *
    *  - Inform the wire object which port it should draw to
    *  - Inform the view that this port is now busy
    */
    register-input: (wire) !->
      @active-inputs += 1
      i = 0
      until @receiving-wires[i] is null
        i++
      else
        throw new Error 'No free ports to connect to'
      wire?set-port i
      @receiving-wires[i] = wire
      @active-view?busy-port i
  
    /** rem-input : void
    *  ref : int
    *  
    *  Redraw port as it's no longer attached to a wire
    * (Note: Actual data stopping is dealt with in output node)r
    */
    rem-input: (ref) ->
      if (ref > @total-inputs) then throw new Error 'Input out of range'
      else
        @receiving-wires[ref-1] = null
        @active-inputs -= 1 
        @active-view?clear-port ref

    /** connect : void
    * wire : Wire

    * For a new wire:
    * - Receiving node should find new input
    * - Outputting node should adjust it's send-list
    *
    *  NOTE:
    *  Currently nothing stopping multiple wires
    * joining the same nodes - this should
    * be prohibited in final edition
    */
    connect: (wire) !->
      if active-inputs = total-inputs then throw new Error 'Connection failed'
      else
       register-input wire
       wire.output-node?register-output (this)


export class Output
  ->

   /** get-output-pos : paper.Point
   *
   *  Requests position of output port from node_view
   */
   get-output-pos: ->
     @active-view?get-output-pos


   /** register-output : void
   * node : Node
   *
   *  Add to the send-list the node 'node'
   */
   register-output: (node) !->
     send-list = [node] ++ send-list

   /** rem-output : void
   * node : Node
   *
   *  Update the send list after a disconnect
   */
   rem-output: (node) !->
     rec-rem-output node, send-list

   rec-rem-output: (k, [x, ...xs]:list) -> 
     |  k == x   => xs
     |  xs == [] => throw new Error 'Remove send node not possible'
     | otherwise => [x] ++ rec-rem-output k, xs


   /** disconnect : void
   * wire : Wire
   *
   * For a removed wire:
   * - Outputting node should adjust its send-list
   * - Receiving node should free input port
   *
   *  NOTE:
   * The wire should have already been informed of its inpending doom,
   * the node does not need to tell it of its demise.
   */
   disconnect: (wire) !->
     rem-input (wire?get-port)
     wire.output-node?rem-output (this)

   /**
   * To implement elsewhere:
   * WIRE:
   * output-node : Returns value of source node
   * set-port ref : Informs the wire which port it is assigned to
   *    - This allows the wire then to be drawn from source node to destination node at this port
   * get-port : Returns the value of the port on which the wire is attached to
   * redraw : Informs the wire that it should redraw its end-point (found by calling node.get-input-pos ref)
   *    - This is called when a node is moved and the wires should move with it
   *
   * NODE_VIEW
   * VARIABLES - Keeps track of number of inputs (as constant after drawn once)
   *    - This allows node_view to make design decisions without requesting values from the node class
   *
   * draw-node location, total : Adjusts the view to show the new node at point 'location' with 'total' input ports
   *    - This is called on creation of a node and should have all inputs marked as free
   * get-input-pos ref : Returns position of port 'ref' if there are 'total' input ports
   * get-output-pos: Returns location of output port
   * busy-port ref : Inform the view that inputs has been changed and should change on screen
   *     - This is called when a wire connects to this node. A free input port is passed as reference and should
   *       be subsequently marked as busy
   * clear-port ref : Inform the view that this input is now not attached and should change on screen
   *     - This is called when a wire is disconnected from this node. The input should become free.
   */
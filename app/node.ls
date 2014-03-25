View = require \node_view

  /**
  * REQUIREMENT
  *
  * Connect and disconnect should always
  * be called on the receiving node
  *
  * Location should always be set on initialising
  * a node
  */

export class Node
  ->

  inputs = 0
  location
  send-list = []
  @active-view = new Node_View
  draw-node (location)

export class Input
  ->

  /**
  *  Pass position request onto view
  * Passes information about intended input and number
  * of total inputs
  * Returns location of input
  */
  get-input-pos: (ref) ->
    @active-view?get-input-pos ref, inputs

  
  /**
  *  Upon a wire connect, inform this node that it
  * may receive data. Wire should remember this and
  * input view should be updated
  */
  register-input: (ref, wire) ->
    inputs = inputs + 1
    wire?set-input
    @active-view?draw-inputs ref, inputs

  
  /**
  *  Upon a wire disconnect, confirm this is a valid
  * input and redraw the view of it -
  * (Note: Actual data stopping is dealt with in output node)
  */
  rem-input: (ref) ->
    if (ref > inputs) then throw new Error 'Input out of range'
    else
      x = 1
      until x == ref draw-inputs x, inputs
      x = x+1
      to x == inputs draw-inputs x, inputs
      inputs = inputs - 1


  /**
  * For a new wire:
  * - Receiving node should open new input and redraw
  * - Outputting node should adjust it's send-to list
  *
  *  NOTE:
  *  Currently nothing stopping multiple wires
  * joining the same nodes - feel this should
  * be prohibited
  */
  connect: (wire) ->
    register-input inputs, wire
    wire.output-node?send-to (this)


export class Output
  ->

  /**
  *  Pass request onto View - no parameters required
  * as there is always only 1 output node
  */
  get-output-pos: ->
    @active-view?get-output-pos


  /**
  *  Update the send list upon a connect to the fact we have
  * a new node that should receive data from this
  */
  send-to: (node) ->
    send-list = [node] ++ send-list

  /**
  *  Update the send list upon a disconnect to the fact the
  * node the wire was joined to is no longer receiving data
  */
  rem-output: (node) ->
    rec-rem-output node, send-list

  rec-rem-output: (k, [x, ...xs]:list) -> 
    |  k == x   => xs
    |  xs == [] => throw new Error 'Remove send node not possible'
    | otherwise => [x] ++ rec-rem-output k, xs


  /**
  * For a removed wire:
  * - Outputting node should adjust it's send-to list
  * - Receiving node should shut inputs and redraw
  * remaining inputs
  */
  disconnect: (wire) ->
    wire.output-node?rem-output (this)
    rem-input (wire.input-ref)


  /**
  * To implement elsewhere:
  * WIRE:
  * output-node : Returns value of node the the wire begins at
  * set-input (ref) : Gives the wire an input port to attach to
  * input-ref : Returns reference of input on the input node (i.e. wire connects to port 3)
  *
  * NODE_VIEW
  * get-input-pos (ref,total) : Returns position of port 'ref' if there are 'total' input ports
  * get-output-pos: Returns location of output port
  * draw-inputs (ref,total): Inform the view that inputs has been changed and should change on screen
  * draw-node (Node): Adjusts the view to show the new node drawn
  */
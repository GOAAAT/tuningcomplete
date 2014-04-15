  /**
  * REQUIREMENT
  *
  * Connect and disconnect should always
  * be called on the receiving node
  *
  * Location and total-inputs should always be set on initialising
  * a node
  */
  
NodeView = require \NodeView

export class Node
  ->

    @location
    @type

    @send-list = []
    
    @numerical = []
    @audio = []
    @active-view = new Node_View

export class Input
  ->

    /** get-input-pos : paper.Point
    *  ref : int
    *
    * Requests the position of port 'ref' from NodeView
    */
    get-input-pos: (ref) ->
      @active-view?get-input-pos ref
  
    /** register-input : int
    * nodetype : NodeType
    *
    *  - Update the list of free ports
    *  - Inform the wire object which port it should draw to
    *  - Inform the view that this port is now busy
    */
    register-input: (nodetype) ->
      i = 0
      while (i < @nodetype.length && @nodetype[i] isnt true)
        i++
      if @nodetype[i] isnt true  
        return -1
      @"nodetype"[i] = false
      overall-port = i
      if (nodetype == numerical)
        overall-port += @audio.length
      @active-view?busy-port overall-port
      i
  
    /** rem-input : void
    *  nodetype : NodeType
    *  ref : int
    *  
    *  - Update the list of free ports
    *  - Inform the wire that this port is now free
    */
    rem-input: (nodetype, ref) ->
      @nodetype[ref] = true
      overall-port = i
      if (nodetype == numerical)
        overall-port += @audio.length
      @active-view?clear-port overall-port



export class Output
  ->

   /** get-output-pos : paper.Point
   *
   *  Requests position of output port from NodeView
   */
   get-output-pos: ->
     @active-view?get-output-pos


   /** register-output : void
   * node : Node
   *
   *  Add to the send-list the node 'node'
   */
   register-output: (node) !->
     @send-list.push node

   /** rem-output : void
   * node : Node
   *
   *  Update the send list after a disconnect
   */
   rem-output: (node) !->

     @send-list = filter (!= node), @send-list


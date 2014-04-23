Input = require \input
NodeView = require \node_view
{head, filter} = prelude

module.exports = class Node

  (@output-type, audio, numerical, pos) ->
    @inputs = []
    for i from 1 to audio
      new Input "Audio", i |> @inputs.push
    for i from 1 to numerical
      new Input "Numerical", (i+audio) |> @inputs.push

    @send-list = []

    @sending-wires = []
    @type = "Standard"
    
    @active-view = new NodeView pos, @type, @output-type, @inputs

  /**view
  **/

  view: (n) -> @active-view?group!
  
  /** find-input : int
  * nodetype : NodeType
  *
  *  - Update the list of free ports
  *  - Inform the wire object which port it should draw to
  *  - Inform the view that this port is now busy
  */
  find-input: (nodetype) ->
    @inputs |> filter (-> it.type == nodetype and not it.busy) |> head
  
  /** get-output-pos : paper.Point
  *
  *  Requests position of output port from node_view
  */
  get-output-pos: ->
    @active-view?get-output-pos!


  /** register-output : void
  * node : Node
  *
  *  Add to the send-list the node 'node'
  */
  register-output: (node) !->
    @send-list.push node
    console.log "Successful register"

  /** rem-output : void
  * node : Node
  *
  *  Update the send list after a disconnect
  */
  rem-output: (node) !->
    @send-list = filter (!= node), @send-list
      
  /** get-output-type() : String
   *
   * Returns output type
   */
   
  get-output-type: !-> @output-type
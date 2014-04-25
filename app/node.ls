Input = require \input
NodeView = require \node_view
{head, filter} = prelude

module.exports = class Node
  /**
  * Construct an input setup that we want. Each input gets
  * a unique reference and is stored in node as @inputs
  */
  (@output-type, audio, numerical, pos) ->
    @inputs = []
    for i from 1 to audio
      new Input "Audio", i |> @inputs.push
    for i from 1 to numerical
      new Input "Numerical", (i+audio) |> @inputs.push

    @send-list = []

    @sending-wires = []
    @type = "Standard"
    
    @active-view = new NodeView pos, @type, @inputs


  view: -> @active-view?group!
  

  /** find-input : Input
  * nodetype : NodeType
  *
  *  Returns the first available Input to be free and of type
  * Nodetype
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


  /** rem-output : void
  * node : Node
  *
  *  Update the send list after a disconnect
  */
  rem-output: (node) !->
    @send-list = filter (!= node), @send-list

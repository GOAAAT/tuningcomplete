Input = require \input
NodeView = require \node_view
VS = require \view_style
{head, filter, each, empty} = prelude

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

    @active-view = new NodeView this, pos, VS.standard, @output-type, @inputs

  view: -> @active-view?item!

  /** find-input : Input
  * nodetype : NodeType
  *
  * Returns the first available Input to be free and of type
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

  /** translate : void
   *
   * Move the Node and any associated wires.
   */
  translate: (pt) !->
    @view!translate pt

    @inputs |> each (input) ->
      input.wire?active-view.wire-end!?add pt
        |> input.wire?active-view.set-end

    @send-list |> each (wire) ->
      wire?active-view.wire-start!?add pt
        |> wire?active-view.set-start

  /** register-output : void
  * wire : Wire
  *
  *  Add to the send-list the wire 'wire'
  */
  register-output: (wire) !->
    @send-list.push wire
    @active-view.busy-out!

  /** rem-output : void
  * node : Node
  *
  *  Update the send list after a disconnect
  */
  rem-output: (node) !->
    @send-list = filter (!= node), @send-list
    @active-view.free-out! if empty @send-list

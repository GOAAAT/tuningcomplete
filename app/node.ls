AudioInput = require \audio_input
NumericalInput = require \numerical_input
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
      new AudioInput this, i |> @inputs.push
    for i from 1 to numerical
      new NumericalInput this, i+audio |> @inputs.push

    @send-list = []

    @active-view = new NodeView this, pos, VS.standard, @output-type, @inputs

  /** view : paper.Item
   *
   * Returns the PaperJS object that represents this controller.
   */
  view: -> @active-view?item!

  /** add-to-window : void
   *  win : Window
   *
   * Adds this classes view to the window
   */
  add-to-window: (win) -> 
    win.insert-children [@view!]
    return true

  /** find-input : Input
  * nodetype : NodeType
  *
  * Returns the first available Input to be free and of type
  * Nodetype
  */
  find-input: (nodetype) ->
    @inputs |> filter (-> it.type == nodetype and not it.busy) |> head

  /** (abstract) receive-for-ref : void
   *  ref : Int
   *  value : Int
   *
   * One of the inputs received a value.
   */
  receive-for-ref: (ref, value) !->

  /** has-output : Boolean
   *
   * Returns whether the node has an output.
   */
  has-output: -> true

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
   *  wire : Wire
   *
   *  Add to the send-list the wire 'wire'.
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

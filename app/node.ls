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
    for i from 0 til audio
      new AudioInput this, i |> @inputs.push
    for i from audio til numerical+audio
      new NumericalInput this, i |> @inputs.push

    @send-list = []

    @active-view = new NodeView this, pos, VS.standard, @output-type, @inputs
    @active-view.set-label "ε", \16pt, false

  /** view : paper.Item
   *
   * Returns the PaperJS object that represents this controller.
   */
  view: -> @active-view?item!

  /** add-to-window : void
   *  win : Window
   *  cb  : Boolean -> ()
   *
   * Adds this classes view to the window. Pass the result on to the callback
   */
  add-to-window: (win, cb) !->
    win.insert-children [@view!]
    cb true

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
    @_move-input-wires pt
    @_move-output-wires pt

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

  /** _move-input-wires : void
   *  pt : paper.Point
   *
   * Move the wires connected to the inputs.
   */
  _move-input-wires: (pt) ->
    @inputs |> each (input) ->
      input.wire?active-view.wire-end!?add pt
        |> input.wire?active-view.set-end

  /** _move-output-wires : void
   *  pt : paper.Point
   *
   * Move the wires connected to the outputs.
   */
  _move-output-wires: (pt) ->
    @send-list |> each (wire) ->
      wire?active-view.wire-start!?add pt
        |> wire?active-view.set-start

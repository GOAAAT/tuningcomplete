WireView = require \wire_view
Input = require \input

/**
* Wires are a visual impression of Node connection, having an
* "origin" connected to a "dest". Actions may be performed on
* "input" which is the input of "dest" which the wire is connnected
* to.
*/

module.exports = class Wire
  (@origin) ->
    @wire-type = @origin?output-type
    @active-view = new WireView @origin?get-output-pos!, "Standard"

  view: -> @active-view?item!

  /** connect : Boolean
  * node : Node
  *
  * Tries to find and set a destination for the wire
  * returns true on successful connection, false otherwise
  */
  connect: (node) ->
     input = node?find-input (@wire-type)
     if input?
       @input = input
       @dest = node
       @input?register-input @
       @origin?register-output node
       @active-view?set-end input?view!position
       @active-view?set-wire-type \Selected
       true
     else
       false

  /** disconnect : Boolean
  *
  * Adjusts both properties of nodes, and removes the wire
  * from view. True unless failure
  */
  disconnect: ->
     @input?remove-input!
     @origin?rem-output @dest
     @active-view?remove!
     true

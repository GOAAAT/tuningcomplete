WireView = require \wire_view

/**
* Wires connect nodes, transferring data from an 'origin' to a 'destination' 
*/

module.exports = class Wire 
  (@origin) ->
    @wire-type = @origin?output-type
    @active-view = new WireView @origin?get-output-pos!, "Standard"

  connect: (node) ->
     input = node?find-input (@wire-type)
     if input?
       @dest = input 
       console.log input
       @origin?register-output node
       @active-view?set-end input?input-view?item!position
       true
     else 
       false
    
  disconnect: !->
     @input?remove-input!
     @origin?rem-output @input
     @active-view?remove!

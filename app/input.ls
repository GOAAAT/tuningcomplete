InputView = require \input_view

module.exports = class Input

  (@type="Standard") ->
    @busy = false
    @input-view = new InputView @type

  view: -> @input-view?item!

  register-input: (wire) !-> 
    @busy = true
    @input-view?busy-port
    @wire = wire

  remove-input: !->
    @busy = false
    @input-view?free-port
    @wire = null
   
export class Output
  ->

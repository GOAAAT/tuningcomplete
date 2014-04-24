InputView = require \input_view

module.exports = class Input
  (@type="Standard", @ref=0) ->
    @busy = false
    @input-view = new InputView @type

  view: -> @input-view?item!

  register-input: (wire) !-> 
    console.log "Found register-input"
    @busy = true
    @input-view?busy-port @ref
    @wire = wire

  remove-input: !->
    @busy = false
    @input-view?free-port
    @wire = null
      
export class Output
  ->
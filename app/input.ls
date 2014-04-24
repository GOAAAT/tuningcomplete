InputView = require \input_view

module.exports = class Input
  (@type="Standard", @ref) ->
    @busy = false
    @input-view = new InputView @type

  view: -> @input-view?item!

  /* register-input : void
  * wire : Wire
  * 
  * Informs this port that it is busy
  */
  register-input: (wire) !-> 
    @busy = true
    @input-view?busy-port!
    @wire = wire

  /* remove-input: void
  *
  * Informs this port that it is free
  */
  remove-input: !->
    @busy = false
    @input-view?free-port!
    @wire = null

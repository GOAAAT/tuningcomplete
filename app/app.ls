LeapCursor = require \leap_cursor
Window     = require \window

module.exports = class App
    (canvas) ->
      @window = new Window canvas
      @cursor = new LeapCursor

      @cursor.set-delegate @window

    init: ->
      @window.activate!
      @cursor.activate!

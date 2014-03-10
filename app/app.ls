LeapCursor = require \leap_cursor
Window     = require \window

module.exports = class App
    (canvas) ->
      @cursor = new LeapCursor
      @window = new Window canvas

      @cursor.set-delegate @window

    init: ->

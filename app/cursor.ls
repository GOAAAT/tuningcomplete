CursorResponder = require \cursor_responder

module.exports = class Cursor
  set-delegate: (obj) ->
    if obj instanceof CursorResponder
      @delegate = obj
    else
      klass-name = obj?constructor?display-name
      throw new TypeError("#klass-name is not a CursorResponder")

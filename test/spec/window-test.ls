Window          = require \window
CursorResponder = require \cursor_responder

describe 'Window' !->
  var win
  before-each !->
    win := new Window

  specify 'is a CursorResponder' ->
    expect(win).to.be.an.instance-of CursorResponder

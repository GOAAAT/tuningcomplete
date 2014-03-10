Cursor          = require \cursor
CursorResponder = require \cursor_responder

describe 'Cursor' !->
  var cursor
  before-each !->
    cursor := new Cursor

  describe '#set-delegate' ->
    specify 'accepts CursorResponders' ->
      responder = new CursorResponder
      expect(-> cursor.set-delegate responder)
        .not.to.throw TypeError

    specify 'does not accept anything else' ->
      responder = {}
      expect(-> cursor.set-delegate responder)
        .to.throw TypeError

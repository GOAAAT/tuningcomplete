CursorResponder = require \cursor_responder

module.exports = class Cursor
  /** set-delegate : void
   *  obj : CursorResponder
   *
   * Set the delegate for the cursor (the object that will respond to the
   * cursor's callbacks).
   */
  set-delegate: (obj) !->
    if obj instanceof CursorResponder
      @delegate = obj
    else
      klass-name = obj?constructor?display-name
      throw new TypeError("#klass-name is not a CursorResponder")

  /** activate : void
   *
   * Start listening for cursor events.
   */
  activate: !->

  /** remove : void
   *
   * Stop listening for cursor events.
   */
  remove: !->

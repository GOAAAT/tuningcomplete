module.exports = class Button
  /** Button
   *  name : String
   *  tag : Object
   *  width : Integer
   *  sticky : Boolean
   *  enabled : Boolean
   *
   * Creates a button with the label `name`, with width `width`.
   * `tag` is an object that is passed on to listeners to identify the button.
   * `sticky` determines whether the button is a toggle button or not, i.e.
   * whether the state of the button sticks or not.
   * `enabled` determines whether the button is initially on or not.
   */
  ({
    name, @tag, width
    @sticky  = false,
    @enabled = false
  }) ->
    @label = new paper.PointText do
      content:     name
      font-family: \Helvetica
      font-weight: \bold
      leading:     20
      font-size:   20

    # Ensure label is the correct size
    @label.scale (width - 20) / @label.bounds.width if width?

    @bg = new paper.Shape.Circle do
      center: [0 0]
      radius: @label.bounds.width / 2 + 10

    @group = new paper.Group [ @bg, @label ]

    # Recenter the label
    @label.position = [0 0]

    # Set the initial state
    if @enabled then @highlight! else @reset!

    # Setup the callbacks
    @group.on \mousedown !~> @highlight!
    @group.on \mouseup   !~> @trigger !@sticky || !@enabled

  /** view : paper.Group
   *
   * Returns the view in the heirarchy that represents the button.
   */
  view: -> @group

  /** set-listener : void
   *  target : Object
   *  method : String
   *
   * Sets the object (`target`) and the function to call on the object
   * (`method`) when the button is triggered.
   */
  set-listener: (target, method) !->
    @_on-click = target[method] @tag, _

  /** trigger : void
   *  state : Boolean
   *
   * Update the state of the button, and notify the listener as such.
   */
  trigger: (state, notify = true) !->
    if @sticky and state then @highlight!
    else                      @reset!

    @_on-click? state if notify
    @enabled = state

  /** highlight : void
   *
   * Highlight the button's view as if it were clicked.
   */
  highlight: !->
    @label.fill-color = \#4A8200
    @bg.fill-color    = \#111

  /** reset : void
   *
   * Reset the button's view, to its unclicked state.
   */
  reset: !->
    @label.fill-color = \white
    @bg.fill-color    = \black

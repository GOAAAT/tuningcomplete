{map, zip, each} = prelude
Color      = require \color
LeapCursor = require \leap_cursor
Window     = require \window
Button     = require \button

module.exports = class App
    /** App
     *  canvas : HTMLCanvasElement
     *
     * Controller class for the entire app (initialises the app's window and
     * the cursor event handler).
     */
    (canvas) ->
      @window = new Window canvas
      @cursor = new LeapCursor

      @cursor.set-delegate @window

    /** init : void
     *
     * Set @window's context as the default graphics context,
     * Set the @cursor as the default handler for cursor events.
     * Create and lay out the buttons for the user interface.
     */
    init: !->
      @window.activate!
      @cursor.activate!

      # New Node List
      @node-list = new FilterList!

      # Test Data only
      data  = new PrefixTree!
      nodes =
        * name: \OSCILLATOR
          node: { desc: "Generates a continuous tone of a given pitch" }
        * name: \MIXER
          node: { desc: "Mix two sources together" }
        * name: \GAIN
          node: { desc: "Control the amplitude of a signal" }
        * name: \SEQUENCER
          node: { desc: "Control properties of signals over time" }

      nodes |> each ({name, node}) !-> data.insert name, node

      @node-list.set-data data
      @node-list.set-listener @~new-node

      @node-list.view!position = [NL_X, NL_Y]
      @node-list.expand NL_WIDTH

      # Node Palette Button
      @add-node-btn = new Button do
        name:     \+
        tag:      0
        sticky:   true
        width:    BTN_WIDTH
        hl-color: Color.blue

      @add-node-btn.view!position = [BTN_OFF, BTN_Y]
      @add-node-btn.set-listener @~add-node

      modes =
        * name:  \DESIGN
          color: Color.red
        * name:  \SETUP
          color: Color.yellow
        * name:  \PERFORM
          color: Color.green

      # Mode Toggle Buttons
      @current-mode = 0
      @mode-btns =
        modes
        |> (ns) -> zip [0 til ns.length] ns
        |> map ([i, {name, color}]) ~>
          btn = new Button do
            name:     name
            tag:      i
            sticky:   true
            enabled:  i == BTN_DEFAULT
            width:    BTN_WIDTH
            hl-color: color

          btn.view!position = [BTN_OFF + (i + 1) * (BTN_WIDTH + BTN_PAD), BTN_Y]
          btn.set-listener @~change-mode
          btn

      [ @add-node-btn, ...@mode-btns ]
        |> map (.view!)
        |> @window.insert-ui

    /** Button properties */
    const BTN_DEFAULT = 0
    const BTN_WIDTH   = 80
    const BTN_OFF     = 70
    const BTN_PAD     = 20
    const BTN_Y       = 70

    /** Button Callbacks */

    /** add-node : void
     *
     * Callback for the Node Palette Button (@add-node-btn). Brings up the list
     * of nodes that can be accessed at this time.
     */
    add-node: !->
      console.log 'Add Node'

    /** change-mode : void
     *  mode : Integer
     *  state : Boolean
     *
     * Callback for Mode Toggle Buttons (@mode-btns). Takes the `mode` that is
     * being changed from/to, and the direction (`state`). If you are leaving
     * a mode without one to go to, you end up at the default mode.
     */
    change-mode: (mode, state) !->
      @current-mode = if state then mode else BTN_DEFAULT

      @mode-btns |> each (btn) !~>
        btn.trigger btn.tag == @current-mode, false

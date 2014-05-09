{map, zip, each} = prelude
Color      = require \color
LeapCursor = require \leap_cursor
Window     = require \window
Button     = require \button
FilterList = require \filter_list
NodeList   = require \node_list

DestinationNode = require \destination_node

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

      # Web Audio Context
      @actx   = new webkit-audio-context!

      @cursor.set-delegate @window

    /** init : void
     *
     * Set @window's context as the default graphics context,
     * Set the @cursor as the default handler for cursor events.
     * Setup the list of nodes that can be added to the current screen.
     * Create and lay out the buttons for the user interface.
     */
    init: !->
      @window.activate!
      @cursor.activate!

      # Destination Node
      @destination = new DestinationNode (paper.view.bounds.right-center.add DEST_OFF), @actx
      @window.insert-children [@destination.view!]

      # Web Audio test
      @osc = @actx.create-oscillator!
      @osc.frequency.value = 440
      @osc.type = "sine"
      # @osc.start 0

      @osc.connect @actx.destination

      # New Node List
      @node-list = new FilterList @window
      @node-list.set-visible false
      @node-list.set-listener @~new-node
      @node-list.view!position = [NL_X, NL_Y]
      @node-list.expand NL_WIDTH

      @node-list.set-data NodeList

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

      @window.insert-ui [ @node-list.view! ]
      @window?force-update!
      

    /** Modes */
    const MODE_DESIGN  = 0
    const MODE_SETUP   = 1
    const MODE_PERFORM = 2

    /** Button properties */
    const BTN_DEFAULT = MODE_DESIGN
    const BTN_WIDTH   = 80px
    const BTN_OFF     = 70px
    const BTN_PAD     = 20px
    const BTN_Y       = 70px

    /** Node List Properties */
    const NL_WIDTH    = BTN_WIDTH * 4 + BTN_PAD * 3
    const NL_X        = BTN_OFF - BTN_WIDTH/2 + NL_WIDTH/2
    const NL_Y        = BTN_Y + BTN_WIDTH + 50px

    const DEST_OFF    = [-100px 0px]

    /** Button Callbacks */

    /** add-node : void
     *
     * Callback for the Node Palette Button (@add-node-btn). Brings up the list
     * of nodes that can be accessed at this time.
     */
    add-node: (_, state) !->
      @node-list.set-visible state

    /** change-mode : void
     *  mode : Integer
     *  state : Boolean
     *
     * Callback for Mode Toggle Buttons (@mode-btns). Takes the `mode` that is
     * being changed from/to, and the direction (`state`). If you are leaving
     * a mode without one to go to, you end up at the default mode.
     *
     * Also ensures that the "Add Node" button is in the off position (i.e. the
     * Node List is not visible) when the mode is changed.
     */
    change-mode: (mode, state) !->
      @window.deselect!
      @current-mode = if state then mode else MODE_DESIGN

      @window.show-perform @current-mode != MODE_DESIGN
      @window.lock-perform @current-mode == MODE_PERFORM

      @add-node-btn.trigger false
      @mode-btns |> each (btn) !~>
        btn.trigger btn.tag == @current-mode, false

    /** new-node : void
     *  _    : Object
     *  name : String
     *  Node : Class
     *
     * Callback for the @node-list FilterList. When a row is selected, this
     * method gets called with the name of the node, and the class from which
     * to construct the new Node.
     */
    new-node: (_, [name, Node]) ->
      @add-node-btn.trigger false
      console.log "New Node #name, #{Node.desc}"

      new-node = new Node paper.view.center, @actx
      new-node.view!visible = false
      new-node.add-to-window @window, (success) ->
        if success
          new-node.view!visible = true
        else
          new-node.view!remove!
          
    theremin: ->
      Wire = require \wire
      Osc = require \oscillator_node
      XY = require \xy-slider
      Gain = require \gain_node
      (o1 = new Osc [990px 550px], @actx).add-to-window @window, (success) !->
      (xy = new XY [700px 400px], @actx).add-to-window @window, (success) !->
      xy.xnode.active-view.node-group.position = [990px 250px]
      xy.ynode.active-view.node-group.position = [760px 550px] 
      (g = new Gain [1270px 409px], @actx).add-to-window @window, (success) !->
      (new Wire g).connect @destination
      (new Wire xy.ynode).connect o1
      (new Wire xy.xnode).connect g
      (new Wire o1).connect g
      @window.force-update!

    piano: ->
      

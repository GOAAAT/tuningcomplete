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
      @window.lock true

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
      @window.lock false
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
      @window.lock false
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
      Wire = require \wire
      Constant = require \constant_node
      Osc = require \oscillator_node
      Audio = require \audio_reset_node
      DelayGain = require \delay_gain_node
      Toggle = require \toggle
      Inverter = require \inverter
      AudioReset = require \audio_reset_node
      Mixer = require \mixer_node
      load-sound = require \load_sound

      notes = ['a','b','c','d','e','f','g']
      top = -150
      y = 210

      dgs = []
      mxs = []
      (c = new Constant [-350px top + 3*y], @actx).set-value 1

      for i til 7
        a = new AudioReset [200px top + i*y], @actx
        file = "sounds/"+notes[i]+"-note.wav"
        load-sound "sounds/goaaat.mp3" (buff) -> a.audio-node.buffer = buff

        dg = new DelayGain [800px top + i*y], @actx
        dgs[i] = dg
        t = new Toggle [350px top - 70 + i*y], @actx
        t.add-to-window @window, (success) !->
          t.input-view._set-sticky false
        i = new Inverter [650px top - 100 + i*y], @actx

        (new Wire c).connect a
        (new Wire a).connect dg
        (new Wire t).connect dg
        (new Wire t).connect i
        (new Wire i).connect dg

      for i til 3
        m = new Mixer [1100px top + y/2 + 2*i*y], @actx
        mxs[i] = m
        (new Wire dgs[i*2+1]).connect m
        (new Wire dgs[i*2]).connect m

      mxs[3] = dgs[6]

      for i til 2
        mxs[i+4] = new Mixer [1400px top + 1.5*y+ 4*i*y], @actx
        (new Wire mxs[i*2+1]).connect mxs[i+4]
        (new Wire mxs[i*2]).connect mxs[i+4]

      m = new Mixer [1700px top + 3.5*y], @actx
      (new Wire mxs[5]).connect m
      (new Wire mxs[4]).connect m

      @destination.active-view.node-group.position = [2000px top + 3.5*y ]
      (new Wire m).connect @destination

      @window.force-update!
      @window.scale-by 0.5

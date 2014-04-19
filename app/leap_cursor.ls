Cursor = require \cursor
CursorResponder = require \cursor_responder

module.exports = class LeapCursor extends Cursor
  ->
    #Store window width and height
    #Value is halved because thats the only way its ever used, so might as well do it once rather than on every resizing
    @_height = paper.view.bounds.height * 0.5
    @_width = paper.view.bounds.width * 0.5

    #Store scaled (to px from mm) height and width of the current interaction box (from the given leapjs frame)
    #Updated every new leap frame
    #See https://developer.leapmotion.com/documentation/javascript/api/Leap.InteractionBox.html#InteractionBox for info.
    @_sw = 0
    @_sh = 0

    #The previous interaction box
    #Kept to use normalize method for vectors in @_point
    @_iBox = Leap.InteractionBox.Invalid

    #Scale to determine how many px per mm in the real world
    @_scale = 4

    # Flags to determine current behaviour, limit the user to doing one thing at a time
    # Waiting state, ready to detect activity.
    @_waiting = true
    # pointer-down has been called, currently tracking and passing on position via pointer-moved
    @_dragging = false
    # tracking a hand and calling pan-by on its movements
    @_panning = false
    # zooming in and out
    @_zooming = false

    #Determines the z region that is used for commands e.g panning and selecting
    #Measured in mm from the origin at the leap motion
    @_active-region = 0
    #Offset the active region for panning to avoid command mixup
    @_pan-offset = 10

    #Store the id of the object we want to watch
    @_id = ""
    #Secondary id for use in tracking both hands for zooming
    @_id2 = ""

    #Variable for holding position vector of an object in the previous frame
    #https://developer.leapmotion.com/documentation/javascript/api/Leap.Vector.html
    @_pv = Leap.vec3.create()

    #Variable for tracking the previous distance between two hands for the zooming function
    @_pd = 0
    
    #Set how slowly a pointer needs to move to select somewhere, same for hands when starting to zoom.
    # Note its the cube that is compared to this, so 1000 equates to 10mm per second
    @_sensitivity = 1000

    #Set how accurately gesture directions need to be
    #Used in pointer-down finger direction and zooming for hands facing each other
    #Needs to be in range (0,1]
    @_dtol = 0.5

    #Set how aligned hands have to be in y axis for zooming
    @_align = 50

    #Minimum zooming amount
    @_zoom-tol = 0.05

    /*
    *  Remember the width and height of the window on resize events
    *  Hopefully this gets resize events?
    */
    paper.view.on 'resize' @~_resize

  _resize: !->
    @_height = paper.view.bounds.height * 0.5
    @_width = paper.view.bounds.width * 0.5



  /*
  *  Sets @_sw and @_sh according to the size of the new interaction box
  *  Scales the mm input to window px with @_scale
  */
  _adjust: (frame) !->
    @_iBox = frame.interaction-box
    @_sh = frame.interaction-box.height*@_scale
    @_sw = frame.interaction-box.width*@_scale

  /*
  *  Function for converting vec3 millimeter coordinates into paperjs window coordinates.
  */
  _point: (v) ->
    #first calculate normalised vector, see leapjs InteractionBox for info
    nv = @_iBox.normalize-point v, false
    #Adjust into absolute window coordinates
    x = (nv[0] - 0.5) * @_sw + @_width
    #Negative for y as leap measures up as positive y, windows measure down as positive y
    y = (0.5 - nv[1]) * @_sh + @_height
    new paper.Point x, y

  /*
  *  Passes pointer information from the given frame to the delegate.
  */
  _send-pointers: (frame) !->
    #if we're in an action currently, only pass useful pointers
    if @_panning
      ptr = new Array()
      #ptr[0] = @_point frame.hand(@_id).stabilized-palm-position
      @delegate.pointers-changed ptr
      return
    if @_dragging
      ptr = new Array()
      #Do we need to send pointer info in this case?
      #ptr[0] = @_point frame.pointable(@_id).stabilized-tip-position()
      @delegate.pointers-changed ptr
      return
    if @_zooming
      ptrs = new Array()
      ptrs[0] = @_point frame.hand(@_id).stabilized-palm-position
      ptrs[1] = @_point frame.hand(@_id2).stabilized-palm-position
      @delegate.pointers-changed ptrs
      return
    len = frame.pointables.length
    pts = new Array()
    n = 0
    for i til len
      pointer = frame.pointables[i]
      if pointer.valid
        pts[n] = @_point pointer.stabilized-tip-position
        n = n+1
    @delegate.pointers-changed pts


  /*
  *  Function for detecting new activity
  */
  _detect: (frame) !->
    #Check for select-at gesture
    len = frame.gestures.length
    for i til len
      gesture = frame.gestures[i]
      if gesture.type == "screenTap"
        @delegate.select-at @_point gesture.position
        return
    hands = frame.hands
    len = hands.length
    #Check for zooming
    for i til len
      hand1 = hands[i]
      for j from i+1 til len
        hand2 = hands[j]
        if @_init-zoom hand1, hand2
          @_waiting = false
          @_zooming = true
          @_id = hand1.id
          @_id2 = hand2.id
          @_pd = hand1.stabilized-palm-position[0] - hand2.stabilized-palm-position[0]
          if @_pd<0 then @_pd = -@_pd
          return
    #Check if we have a pointable in the active region of low speed (aka, a pointer-down event)
    #take the first matching pointable as the selecting pointer
    ptrs = frame.pointables
    len = ptrs.length
    for i til len
      if ptrs[i]?.valid && ptrs[i].stabilized-tip-position[2] < @_active-region
        if @_speed(ptrs[i].tip-velocity) < @_sensitivity && ptrs[i].direction[2]< -@_dtol
          # pointable object in the active region and 'stationary'
          @_dragging = true
          @_waiting = false
          @_id = ptrs[i].id
          @_pv = ptrs[i].stabilized-tip-position
          @delegate.pointer-down @_point @_pv
          return

    #Finally check if we have a hand in the active region for panning
    len = hands.length
    for i til len
      if hands[i].stabilized-palm-position[2] < @_active-region - @_pan-offset
        @_waiting = false
        @_panning = true
        @_id = hands[i].id
        @_pv = hands[i].stabilized-palm-position
        return

  /*
  *  Test if two hands are positioned to initialise zooming mode
  */
  _init-zoom: (hand1,hand2) ->
    #Check these are valid hand instances
    if !hand1.valid || !hand2.valid then return false
    #Check they're approximately level with each other in y axis
    if !(-@_align < hand1.stabilized-palm-position[1] - hand2.stabilized-palm-position[1] < @_align) then return false
    #Check the hands are slow to start gesture
    if @_speed(hand1.palm-velocity) > @_sensitivity  ||  @_speed(hand2.palm-velocity) > @_sensitivity then return false
    #Check palms are facing horizontally
    if !(@_horiz(hand1) && @_horiz(hand2)) then return false
    true
  
  /*
  *  Similar to init-zoom, but doesn't check hands are low speed
  */
  _cont-zoom: (hand1,hand2) ->
    #Check these are valid hand instances
    if !hand1.valid || !hand2.valid then return false
    #Check they're approximately level with each other in y axis
    if !(-@_align < hand1.stabilized-palm-position[1] - hand2.stabilized-palm-position[1] < @_align) then return false
    #Check plams are facing horizontally
    if !(@_horiz(hand1) && @_horiz(hand2)) then return false
    true

  /*
  *  Get the cube of the speed of a vector
  */
  _speed: (v) ->
    (v[0] * v[0]) + (v[1] * v[1]) + (v[2] * v[2])

  /*
  *  Check if the palm normal is horizontal and perpendicular to screen normal (aka pointing sideways)
  */
  _horiz: (hand) ->
    x-component = hand.palm-normal[0]
    -@_dtol > x-component || x-component > @_dtol

  _drag: (frame) !->
    pointer = frame.pointable(@_id)
    if !pointer.valid || pointer.stabilized-tip-position[2] > @_active-region
      @_waiting = true
      @_dragging = false
      @delegate.pointer-up @_point @_pv
    else
      @_pv = pointer.stabilized-tip-position
      @delegate.pointer-moved @_point @_pv

  _pan: (frame) !->
    hand = frame.hand(@_id)
    if !hand.valid || hand.stabilized-palm-position[2] > @_active-region - @_pan-offset
      @_waiting = true
      @_panning = false
    else
      delta-x = (@_pv[0] - hand.stabilized-palm-position[0]) * @_scale
      delta-y = (hand.stabilized-palm-position[1] - @_pv[1]) * @_scale
      @delegate.pan-by new paper.Point delta-x, delta-y
      @_pv = hand.stabilized-palm-position

  _zoom: (frame) !->
    hand1 = frame.hand(@_id)
    hand2 = frame.hand(@_id2)
    if !@_cont-zoom hand1, hand2
      @_waiting = true
      @_zooming = false
    else
      #set @_pv to the average of the palm positions for a centre point to scale around
      Leap.vec3.add @_pv, hand1.stabilized-palm-position, hand2.stabilized-palm-position
      Leap.vec3.scale @_pv, 0.5
      #get the positive distance between them in x axis
      d = hand1.stabilized-palm-position[0] - hand2.stabilized-palm-position[0]
      if d<0 then d = -d
      #flip this to alter zooming direction
      sf = d/@_pd
      #don't scale by too small amounts
      if 1 - @_zoom-tol < sf < 1 + @_zoom-tol then return
      @delegate.scale-by sf, @_point @_pv
      @_pd = d

  /** 
  *  Callback function for dealing with a frame from the leap motion device.
  *  Passed to the LeapMotion controller object to receive frame events.
  *  Bound to the instance of leap_cursor, so we can get the right behaviour on callback
  */
  _on-frame: (frame)!~>
    if !frame.valid
      #invalid frame instance from the controller
      return
    @_adjust frame
    @_send-pointers frame
    if @_waiting
      @_detect frame
    else if @_dragging
      @_drag frame
    else if @_panning
      @_pan frame
    else if @_zooming
      @_zoom frame

  /*
  *  Activate the leap_cursor instance.
  */
  activate: !->
    @_controller = new Leap.Controller enable-gestures:true
    @_controller.on 'frame', @_on-frame
    @_controller.connect()
  
  /*
  *  Disconnect the leap_cursor instance.
  */
  remove: !->
    @_controller.disconnect()

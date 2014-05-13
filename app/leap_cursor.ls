{map, filter, head, abs} = prelude

Cursor = require \cursor
CursorResponder = require \cursor_responder
PointInfo = require \point_info

#Set how slowly a pointer needs to move to select somewhere, same for hands when starting to zoom.
# Note its the square that is compared to this, so 1000 equates to ~30mm per second
const SENSITIVITY = 4000

#Set how accurately gesture directions need to be
#Used in pointer-down finger direction and zooming for hands facing each other
#Needs to be in range (0,1]
const DTOL = 0.5

#Set how aligned hands have to be in y axis for zooming
const ALIGN = 50

#Determines the z region that is used for commands e.g panning and selecting
#Measured in mm from the origin at the leap motion
const ACTIVE-REGION = -20
#Offset the active region for panning to avoid command mixup
#Must be non-zero (for normalisation purposes when passing z information to CursorResponder)
const PAN-OFFSET = 20

#Scale to determine how many px per mm in the real world
const SCALE = 4

#Minimum zooming amount
const ZOOM-TOL = 0.05

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
    @_i-box = Leap.InteractionBox.Invalid

    # Flags to determine current behaviour, limit the user to doing one thing at a time
    # Waiting state, ready to detect activity.
    @_waiting = true
    # pointer-down has been called, currently tracking and passing on position via pointer-moved
    @_dragging = false
    # tracking a hand and calling pan-by on its movements
    @_panning = false
    # zooming in and out
    @_zooming = false

    #Store the ids of the objects we want to watch
    @_object-id = []

    #Variable for holding position vector of an object in the previous frame
    #https://developer.leapmotion.com/documentation/javascript/api/Leap.Vector.html
    @_pv = Leap.vec3.create!

    #Variable for tracking the previous distance between two hands for the zooming function
    @_pd = 0

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
  *  Scales the mm input to window px with SCALE
  */
  _adjust: (frame) !->
    @_i-box = frame.interaction-box
    @_sh = frame.interaction-box.height*SCALE
    @_sw = frame.interaction-box.width*SCALE

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

  _point-info: (v,type) ->
    pt = @_point v
    new PointInfo pt, type, @_z-norm v[2]

  /*
  *  Normalises the z component to: activeregion < 0 and < panregion < 1
  */
  _z-norm: (z) ->  (z - ACTIVE-REGION)/PAN-OFFSET


  /*
  *  Passes pointer information from the given frame to the delegate.
  */
  _send-pointers: (frame) !->
    #if we're in an action currently, only pass useful pointers
    if @_panning
      ptr = []
      ptr[0] = @_point-info frame.hand(@_object-id[0]).stabilized-palm-position, \pan
      @delegate.pointers-changed ptr
      return
    if @_dragging
      ptr = []
      ptr[0] = @_point-info frame.pointable(@_object-id[0]).stabilized-tip-position, \drag
      @delegate.pointers-changed ptr
      return
    if @_zooming
      ptrs = []
      ptrs[0] = @_point-info frame.hand(@_object-id[0]).stabilized-palm-position, \zoom
      ptrs[1] = @_point-info frame.hand(@_object-id[1]).stabilized-palm-position, \zoom
      @delegate.pointers-changed ptrs
      return
    fingers = frame.pointables
        |> filter (.valid)
        |> map (pt) ~> @_point-info pt.stabilized-tip-position, \finger
    hands = frame.hands
        |> filter (.valid)
        |> map (hand) ~> @_point-info hand.stabilized-palm-position, \hand
    @delegate.pointers-changed (fingers ++ hands)


  /*
  *  Function for detecting new activity
  */
  _detect: (frame) !->
    #Check for select-at gesture
    tap = frame.gestures
        |> filter  ((gesture) -> gesture.type == "screenTap" || gesture.type == "keyTap")
        |> head
    if tap?
      tap.position |> @_point |> @delegate.select-at
      return

    #Check for zooming
    len = frame.hands.length
    for i til len
      hand1 = frame.hands[i]
      for j from i+1 til len
        hand2 = frame.hands[j]
        if @_can-init-zoom hand1, hand2
          @_waiting = false
          @_zooming = true
          @_object-id[0] = hand1.id
          @_object-id[1] = hand2.id
          @_pd = hand1.stabilized-palm-position[0] - hand2.stabilized-palm-position[0] |> abs
          return

    #Check if we have a pointable in the active region of low speed (aka, a pointer-down event)
    #take the first matching pointable as the selecting pointer
    point = frame.pointables
        |> filter (.valid)
        |> filter (.stabilized-tip-position[2] < ACTIVE-REGION)
        |> filter ~> ((@_speed it.tip-velocity) < SENSITIVITY)
        |> filter (.direction[2] < -DTOL)
        |> filter (.hand!.fingers.length == 1)
        |> head

    #pointable object in the active region and 'stationary'
    if point?
      @_dragging = true
      @_waiting = false
      @_object-id[0] = point.id
      @_pv = point.stabilized-tip-position
      @_pv |> @_point |> @delegate.pointer-down
      return

    hand = frame.hands
        |> filter (.stabilized-palm-position[2] < ACTIVE-REGION + PAN-OFFSET)
        |> filter (.fingers.map ((finger) -> finger.time-visible > 0.5) .length == 0)
        |> filter (hand) ->
          x = hand.stabilized-palm-position[0]
          -200 < x < 200
        |> head
    if hand?
      @_waiting = false
      @_panning = true
      @_object-id[0] = hand.id
      @_pv = hand.stabilized-palm-position
      return

  /*
  *  Test if two hands are positioned to initialise zooming mode
  */
  _can-init-zoom: (hand1,hand2) ->
    #Check these are valid hand instances
    !(!hand1.valid || !hand2.valid) &&
    #Check they're approximately level with each other in y axis
    (-ALIGN < hand1.stabilized-palm-position[1] - hand2.stabilized-palm-position[1] < ALIGN) &&
    #Check the hands are slow to start gesture
    !(@_speed(hand1.palm-velocity) > SENSITIVITY  ||  @_speed(hand2.palm-velocity) > SENSITIVITY) &&
    #Check palms are facing horizontally
    (@_horiz(hand1) && @_horiz(hand2))

  /*
  *  Similar to init-zoom, but doesn't check hands are low speed
  */
  _cont-zoom: (hand1,hand2) ->
    #Check these are valid hand instances
    !(!hand1.valid || !hand2.valid) &&
    #Check they're approximately level with each other in y axis
    (-ALIGN < hand1.stabilized-palm-position[1] - hand2.stabilized-palm-position[1] < ALIGN) &&
    #Check plams are facing horizontally
    (@_horiz(hand1) && @_horiz(hand2))

  /*
  *  Get the sqaure of the speed of a vector
  */
  _speed: (v) ->
    (v[0] * v[0]) + (v[1] * v[1]) + (v[2] * v[2])

  /*
  *  Check if the palm normal is horizontal and perpendicular to screen normal (aka pointing sideways)
  */
  _horiz: (hand) ->
    x-component = hand.palm-normal[0]
    -DTOL > x-component || x-component > DTOL

  _drag: (frame) !->
    pointer = frame.pointable @_object-id[0]
    if !pointer.valid || pointer.stabilized-tip-position[2] > ACTIVE-REGION
      @_waiting = true
      @_dragging = false
      @_pv |> @_point |> @delegate.pointer-up
    else
      @_pv = pointer.stabilized-tip-position
      @_pv |> @_point |> @delegate.pointer-moved

  _pan: (frame) !->
    hand = frame.hand(@_object-id[0])
    if !hand.valid || hand.stabilized-palm-position[2] > (ACTIVE-REGION+PAN-OFFSET) || hand.fingers.map ((finger) -> finger.time-visible > 0.5) .length != 0
      @_waiting = true
      @_panning = false
    else
      delta-x = (@_pv[0] - hand.stabilized-palm-position[0]) * SCALE
      delta-y = (hand.stabilized-palm-position[1] - @_pv[1]) * SCALE
      @delegate.pan-by new paper.Point delta-x, delta-y
      @_pv = hand.stabilized-palm-position

  _zoom: (frame) !->
    hand1 = frame.hand @_object-id[0]
    hand2 = frame.hand @_object-id[1]
    if !@_cont-zoom hand1, hand2
      @_waiting = true
      @_zooming = false
    else
      #set @_pv to the average of the palm positions for a centre point to scale around
      Leap.vec3.add @_pv, hand1.stabilized-palm-position, hand2.stabilized-palm-position
      Leap.vec3.scale @_pv, @_pv, 0.5
      #get the positive distance between them in x axis
      d = hand1.stabilized-palm-position[0] - hand2.stabilized-palm-position[0] |> abs

      #flip this to alter zooming direction
      sf = d/@_pd
      #don't scale by too small amounts
      if -ZOOM-TOL < sf - 1 <ZOOM-TOL then return
      @delegate.scale-by sf, @_point @_pv
      @_pd = d

  /**
  *  Callback function for dealing with a frame from the leap motion device.
  *  Passed to the LeapMotion controller object to receive frame events.
  *  Bound to the instance of leap_cursor, so we can get the right behaviour on callback
  */
  _on-frame: (frame)!->
    if !frame.valid
      #invalid frame instance from the controller
      return
    @_adjust frame
    if @_waiting
      @_detect frame
    else if @_dragging
      @_drag frame
    else if @_panning
      @_pan frame
    else if @_zooming
      @_zoom frame
    @_send-pointers frame

  /*
  *  Activate the leap_cursor instance.
  */
  activate: !->
    @_controller = new Leap.Controller enable-gestures:true
    @_controller.on 'frame', @~_on-frame
    @_controller.connect!

  /*
  *  Disconnect the leap_cursor instance.
  */
  remove: !->
    @_controller.disconnect()

/*
*  Class to pass useful info between leap_cursor and window via pointers-changed
*
*  Public Methods:
*  PointInfo(t,type,z): sets up the PointInfo object
*/

module.exports = class PointInfo
  /*
  *  PointInfo(@pt : paper.Point, @type : String, @z: Num)
  *  type = \hand => hand object
  *       = \finger => pointable object
  *       = \zoom => hand while zooming
  *       = \pan => hand while panning
  *  pt is just a paper.Point representing x, y coords (in px)
  *  z is 'currently' just the displacement along the z axis in mm from the leap motion, this may change depending on needs.
  */
  (@pt, @type, @z) ->

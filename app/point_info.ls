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
  *  z is a normalised value, with positive direction aay form the screen, 0 at activeregion boundary, 1 at panning region boundary
  */
  (@pt, @type, @z) ->

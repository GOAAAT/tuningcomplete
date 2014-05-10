/** load-sound : void
 *  file : String
 *  callback : ArrayBuffer -> ()
 *
 * Loads file from given location and passes it on as an ArrayBuffer
 * to the callback.
 */
module.exports = (file, callback) !->
  xhr = new XMLHttpRequest!
  xhr.open \GET, file, true
  xhr.response-type = \arraybuffer
  xhr.onload = (e) -> callback @response
  xhr.send!

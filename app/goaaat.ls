export load-sound = (callback) ->
  xhr = new XMLHttpRequest!
  xhr.open \GET "sounds/goaaat.mp3" true
  xhr.response-type = \arraybuffer
  xhr.onload = (e) -> callback @response
  xhr.send!

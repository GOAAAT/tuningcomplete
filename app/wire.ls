/**
* Wires connect nodes, transferring data from an 'origin' to a 'destination' 
*/

export class Wire
  (node) ->
    @origin = node


  @origin
  @dest
  @dest-port
  @wire-type = @origin.type
  @active-view = new Wire_View
  @active-view.set-start(node.get-output-pos!) # not actually necessary

  
  /** redraw: void
  * Informs the wire that it should redraw its end-point
  *  (called when a node is moved, so the wires can move with it)
  */
   redraw: !-> active-view.redraw

   connect: (node) !->
     @dest-port = node.register-input (@wire-type)
     if (@dest-port == -1)
XX     @active-view.remove!
     else 
       @dest = node
       @origin?register-output node
XX     @active-view.set-end(node.get-output-pos!)
    

   disconnect: !->
     @dest?rem-input (@wire-type, @dest-port)
     @orgin?rem-output @dest
XX   @active-view.remove!
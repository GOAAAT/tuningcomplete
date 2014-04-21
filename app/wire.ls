/**
* Wires connect nodes, transferring data from an 'origin' to a 'destination' 
*/

export class Wire 
   (@origin) ->
   @wire-type = @origin.output-type
   @active-view = new Wire_View
   @active-view.set-start(node.get-output-pos!) # not actually necessary

  
   /** redraw: void 
   * Informs the wire that it should redraw its end-point
   *  (called when a node is moved, so the wires can move with it)
   */
   redraw: !-> active-view.redraw

   connect: (node) ->
     input = node.find-input (@wire-type)
     if input?
       @dest = input 
       @origin?register-output node
       @active-view.set-end(input?view!position) 
       true
     else 
       false
    

   disconnect: !->
     @input?remove-input
     @origin?rem-output @input
     @active-view.remove!

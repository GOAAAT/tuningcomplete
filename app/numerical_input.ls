Input = require \input

module.exports = class NumericalInput extends Input
  /** NumericalInput
   *  ref : Int
   *
   * Creates a numerical input that is in the `ref`th position of its Node.
   */
  (node, ref) -> super \Numerical node, ref

  /** receive : void
   *  value : Int
   *
   * Receive a value and pass it on to the owning Node.
   */
  receive: (value) -> @node.receive-for-ref @ref, value

Input = require \input

module.exports = class AudioInput extends Input
  /** AudioInput
   *  ref : Int
   *
   * Creates an audio input that is in the `ref`th position of its Node.
   */
  (node, ref) -> super \Audio node, ref

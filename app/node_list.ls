Node       = require \node
PrefixTree = require \prefix_tree
Numerical  = require \numerical_node
Audio      = require \audio_node
Oscillator = require \oscillator_node
GainNode   = require \gain_node
MixerNode  = require \mixer_node
PitchNode  = require \pitch
{each}     = prelude

class SimpleNumerical extends Numerical
  @desc = "produces a numerical output"
  (pos) -> super 1 1 pos

class SimpleAudio extends Audio
  @desc = "produces audio output"
  (pos) -> super 1 1 pos

# Test Data only
data  = new PrefixTree!
nodes =
  * name: \oscillator
    node: Oscillator
  * name: \gain
    node: GainNode
  * name: \mixer
    node: MixerNode
  * name: \numerical
    node: SimpleNumerical
  * name: \audio
    node: SimpleAudio
  * name: \pitch
    node: PitchNode

nodes |> each ({name, node}) !-> data.insert name, node

module.exports = data

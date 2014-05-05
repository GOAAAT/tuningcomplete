Node       = require \node
PrefixTree = require \prefix_tree
Numerical  = require \numerical_node
Audio      = require \audio_node
Oscillator = require \oscillator_node
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
  * name: \numerical
    node: SimpleNumerical
  * name: \audio
    node: SimpleAudio

nodes |> each ({name, node}) !-> data.insert name, node

module.exports = data

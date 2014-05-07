Node       = require \node
PrefixTree = require \prefix_tree
Numerical  = require \numerical_node
Audio      = require \audio_node
Slider     = require \slider
Toggle     = require \toggle
XYSlider   = require \xy-slider
Oscillator = require \oscillator_node
GainNode   = require \gain_node
MixerNode  = require \mixer_node
{each}     = prelude

class SimpleNumerical extends Numerical
  @desc = "produces a numerical output"
  (pos) -> super 0 2 pos

class SimpleAudio extends Audio
  @desc = "produces audio output"
  (pos) -> super 1 1 pos
  
class SimpleSlider extends Slider
  @desc = "produces a numerical output in [0..1]"
  (pos) -> super pos
  
class SimpleToggle extends Toggle
  @desc = "produces a numerical output in {0, 1}"
  (pos) -> super pos
  
class SimpleXYSlider extends XYSlider
  @desc = "produces a numerical output in [[0..1], [0..1]]"
  (pos) -> super pos

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
  * name: \slider
    node: SimpleSlider
  * name: \toggle
    node: SimpleToggle
  * name: \xyslider
    node: SimpleXYSlider

nodes |> each ({name, node}) !-> data.insert name, node

module.exports = data

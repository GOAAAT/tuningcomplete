Node       = require \node
PrefixTree = require \prefix_tree
{each}     = prelude

# Test Data only
data  = new PrefixTree!
nodes =
  * name: \oscillator
    node: require \oscillator_node
  * name: \gain
    node: require \gain_node
  * name: \mixer
    node: require \mixer_node
  * name: \slider
    node: require \slider
  * name: \toggle
    node: require \toggle
  * name: \xyslider
    node: require \xy-slider
  * name: \audioresetnode
    node: require \audio_reset_node
  * name: \audiopausenode
    node: require \audio_pause_node

nodes |> each ({name, node}) !-> data.insert name, node

module.exports = data

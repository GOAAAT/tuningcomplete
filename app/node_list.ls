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
  * name: \delaygain
    node: require \delay_gain_node
  * name: \mixer
    node: require \mixer_node
  * name: \slider
    node: require \slider
  * name: \toggle
    node: require \toggle
  * name: \xyslider
    node: require \xy-slider
  * name: \audioreset
    node: require \audio_reset_node
  * name: \audiopause
    node: require \audio_pause_node
  * name: \constant
    node: require \constant_node
  * name: \nand
    node: require \nand_node
  * name: \add
    node: require \add_node
  * name: \inverter
    node: require \inverter
  * name: \delay
    node: require \delay_node
  * name: \multiply
    node: require \mult_node
  * name: \subtract
    node: require \sub_node

nodes |> each ({name, node}) !-> data.insert name, node

module.exports = data

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
  * name: \aslider
    node: require \slider
  * name: \atoggle
    node: require \toggle
  * name: \axyslider
    node: require \xy-slider

nodes |> each ({name, node}) !-> data.insert name, node

module.exports = data

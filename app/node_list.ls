Node = require \node
PrefixTree = require \prefix_tree
{each} = prelude

class Numerical extends Node
  @desc = "produces a numerical output"
  (pos) -> super \Numerical 1 1 pos

class Audio extends Node
  @desc = "produces audio output"
  (pos) -> super \Audio 1 1 pos

# Test Data only
data  = new PrefixTree!
nodes =
  * name: \numerical
    node: Numerical
  * name: \audio
    node: Audio

nodes |> each ({name, node}) !-> data.insert name, node

module.exports = data

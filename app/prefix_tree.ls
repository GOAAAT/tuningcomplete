{empty, split-at, join} = prelude

module.exports = class PrefixTree
  ->
    @version = 0
    @filter-str = ''
    @sub-tree = {}

  get: (key) ->
    @_traverse key,
      base: ~> @obj
      recurse: (h, t) ~> @sub-tree[h]?get t

  insert: (key, obj) !->
    @version++
    @_traverse key,
      base: !~> @obj = obj
      recurse: (h, t) !~> ( @sub-tree[h] ||= new PrefixTree! ).insert t, obj

  contains: (key) ->
    !!@_traverse key,
      base: ~> @obj?
      recurse: (h, t) ~> @sub-tree[h]?contains t

  filter: (key) -> @_filter key, @filter-str

  iterator: -> new PTreeIterator @

  _filter: (key, filter-str) ->
    @_traverse key,
      base: ~> @ with filter-str: filter-str
      recurse: (h, t) ~> @sub-tree[h]?_filter t, join '' [filter-str, h]

  _traverse: (key, {base, recurse}) ->
    [f, r] = split-at @filter-str.length, key
    if @filter-str == f then
      if r == '' then base!
      else
        [h, t] = split-at 1 r
        recurse h, t

class PTreeIterator
  (tree) ->
    @version = tree.version
    @call-stack = new Array {sub: \a tree: tree}
    @_find-next! unless tree.obj?

  next: ->
    if @is-done!
      throw RangeError 'Iterator finished!'

    if @version != @call-stack.0.tree.version
      throw ReferenceError 'Iterator invalidated!'

    ret = @_head!
    @_find-next!
    ret

  is-done: -> empty @call-stack

  _find-next: !->
    {tree: last_t} = @call-stack[*-1]
    do
      {sub, tree} = @call-stack[*-1]
      if tree?sub-tree[sub]?
        @call-stack.push do
          sub:  \a
          tree: tree.sub-tree[sub]
      else
        @call-stack.pop! if sub == \z
        @call-stack[*-1]?sub = @_inc @call-stack[*-1]?sub
    until @is-done! or @_head!? and @call-stack[*-1]?tree != last_t

  _head: -> @call-stack[*-1]?tree?obj

  _inc: (k) -> k?char-code-at 0 |> (1+) |> String.from-char-code

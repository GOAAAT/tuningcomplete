{empty, split-at, join} = prelude

module.exports = class PrefixTree
  ->
    @version  = 0
    @init-str = ''
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

  filter: (key) -> @_filter key, @init-str

  iterator: -> new PTreeIterator @

  _filter: (key, init-str) ->
    @_traverse key,
      base: ~> @ with init-str: init-str
      recurse: (h, t) ~> @sub-tree[h]?_filter t, join '' [init-str, h]

  _traverse: (key, {base, recurse}) ->
    [f, r] = split-at @init-str.length, key
    if @init-str == f then
      if r == '' then base!
      else
        [h, t] = split-at 1 r
        recurse h, t

class PTreeIterator
  (tree) ->
    @version = tree.version
    @call-stack = new Array {pref: tree.init-str, sub: \a tree: tree}
    @_find-next! unless tree.obj?

  next: ->
    if @is-done!
      throw RangeError 'Iterator finished!'

    if @version != @_begin!version
      throw ReferenceError 'Iterator invalidated!'

    {pref, tree: {obj}} = @call-stack[*-1]
    @_find-next!
    [ pref, obj ]

  is-done: -> empty @call-stack

  _find-next: !->
    last_t = @_end!
    do
      {pref, sub, tree} = @call-stack[*-1]
      if tree?sub-tree[sub]?
        @call-stack.push do
          pref: pref + sub
          sub:  \a
          tree: tree.sub-tree[sub]
      else
        @call-stack.pop! if sub == \z
        @_step-head!
    until @is-done! or @_end!obj? and @_end! != last_t

  _begin: -> @call-stack.0?tree

  _end: -> @call-stack[*-1]?tree

  _step-head: !->
    @call-stack[*-1]?sub = @_inc @call-stack[*-1]?sub

  _inc: (k) -> k?char-code-at 0 |> (1+) |> String.from-char-code

{keys, empty, head, tail, split-at, join, sort} = prelude

module.exports = class PrefixTree
  /** PrefixTree
   *
   * A finite mapping from strings to objects, with the ability to filter by
   * prefix, and iterate in alphabetic order.
   */
  ->
    @version  = 0
    @init-str = ''
    @sub-tree = {}

  /** get : Object
   *  key : String
   *
   * Returns the object mapped to the string `key` if it exists. If it does not,
   * returns undefined.
   */
  get: (key) ->
    @_traverse key,
      base: ~> @obj
      recurse: (h, t) ~> @sub-tree[h]?get t

  /** insert : void
   *  key : String
   *  obj : Object
   *
   * Inserts `obj` under the string `key` in the prefix tree.
   */
  insert: (key, obj) !->
    @version++
    @_traverse key,
      base: !~> @obj = obj
      recurse: (h, t) !~> ( @sub-tree[h] ||= new PrefixTree! ).insert t, obj

  /** contains : Boolean
   *  key : Stringo
   *
   * Returns true if the prefix tree maps `key` to some object, and false
   * otherwise.
   */
  contains: (key) ->
    !!@_traverse key,
      base: ~> @obj?
      recurse: (h, t) ~> @sub-tree[h]?contains t

  /** filter : PrefixTree
   *  key : String
   *
   * Returns a PrefixTree containing all the mappings where the string being
   * mapped begins with `key`, relative to any already applied filters.
   */
  filter: (key) -> @_filter key, @init-str

  /** iterator : PTreeIterator
   *
   * Returns an iterator for the current prefix tree. If the tree is modified
   * then the iterator will become invalidated.
   */
  iterator: -> new PTreeIterator @

  /** (private) _filter : PrefixTree
   *  key : String
   *  init-str : String
   *
   * Performs the filtering operation with a custom prefix (`init-str`)
   */
  _filter: (key, init-str) ->
    @_traverse key,
      base: ~> @ with init-str: init-str
      recurse: (h, t) ~> @sub-tree[h]?_filter t, join '' [init-str, h]

  /** (private) _traverse : T
   *  key : String
   *  {
   *    base : Unit -> T
   *    recurse : (Char, String) -> T
   *  }
   *
   * Generalisation of recursive PrefixTree traversal.
   */
  _traverse: (key, {base, recurse}) ->
    [f, r] = split-at @init-str.length, key
    if @init-str == f then
      if r == '' then base!
      else
        [h, t] = split-at 1 r
        recurse h, t

class PTreeIterator
  /** (private) PTreeIterator
   *  tree : PrefixTree
   *
   * Iterator for the prefix tree `tree`, in alphabetic order of keys.
   */
  (tree) ->
    @version = tree.version
    @call-stack = new Array {
      pref: tree.init-str
      subs: @_keys tree
      tree: tree
    }

    @_find-next! unless tree.obj?

  /** next : Object
   *
   * Returns the next element, if one exists. If there are no elements left,
   * then it throws a `RangeError`. If the iterator is out of date (and thus
   * invalidated), it throws a `ReferenceError`.
   */
  next: ->
    if @is-done!
      throw RangeError 'Iterator finished!'

    if @version != @_begin!version
      throw ReferenceError 'Iterator invalidated!'

    {pref, tree: {obj}} = @call-stack[*-1]
    @_find-next!
    [ pref, obj ]

  /** is-done : Boolean
   *
   * Returns true if there are no elements left to iterate over.
   */
  is-done: -> empty @call-stack

  /** (private) _find-next : void
   *
   * Traverses the tree in-order, until the top of the call stack contains an
   * object that can be outputted in the following call to `next`.
   */
  _find-next: !->
    last_t = @_end!
    popped = false
    do
      {pref, subs, tree} = @call-stack[*-1]
      popped = empty subs
      if popped
        @call-stack.pop!
      else
        key  = subs.0
        next = tree.sub-tree[key]
        @_step-head!
        @call-stack.push do
          pref: pref + key
          subs: @_keys next
          tree: next
    until @is-done! or @_end!obj? and @_end! != last_t and not popped

  /** (private) _begin : PrefixTree
   *
   * The tree the iterator started at.
   */
  _begin: -> @call-stack.0?tree

  /** (private) _end : PrefixTree
   *
   * The tree the iterator is currently at.
   */
  _end: -> @call-stack[*-1]?tree

  /** (private) _step-head : void
   *
   * Move the current iterator forward by one character.
   */
  _step-head: !->
    @call-stack[*-1]?subs.shift!

  /** (private) _keys : [String]
   *  tree : PrefixTree
   *
   * Returns the keys for the PrefixTree in alphabetic order.
   */
  _keys: (tree) -> sort keys tree.sub-tree

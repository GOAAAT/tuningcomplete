{each, map} = prelude
PrefixTree = require \prefix_tree

describe 'PrefixTree' !->
  var tree
  before-each !->
    tree := new PrefixTree!

  describe '#get' !->
    describe 'when the key exists' !->
      before-each !->
        tree.insert \key \value

      specify 'it returns the value' !->
        expect( tree.get \key ).to.eql \value

    describe 'when the key does not exist' !->
      specify 'it returns undefined' !->
        expect( tree.get \key ).to.be.undefined

  describe '#insert' !->
    specify 'it adds elements' !->
      tree.insert \key \value
      expect( tree.contains \key ).to.be.true

  describe '#contains' !->
    describe 'when queried about elements in the tree' !->
      before-each !->
        tree.insert \key \value

      specify 'returns true' !->
        expect( tree.contains \key ).to.be.true

    describe 'when queried about element not in the tree' !->
      specify 'returns false' !->
        expect( tree.contains \key ).to.be.false

  describe '#filter' !->
    var subject
    before-each !->
      <[ a abc b bbc ]> |> each tree.insert _, \value
      subject := tree.filter \a

    specify 'it returns a PrefixTree' !->
      expect( subject ).to.be.an.instance-of PrefixTree

    specify 'it keeps matching strings' !->
      expect( subject.contains \a ).to.be.true
      expect( subject.contains \abc ).to.be.true

    specify 'it removes non-matching strings' !->
      expect( subject.contains \b ).to.be.false
      expect( subject.contains \bbc ).to.be.false

    describe 'when the filter is empty' !->
      specify 'it returns undefined' !->
        expect(tree.filter \c).to.be.undefined

  describe '#iterator' !->
    var subject, elems
    before-each !->
      elems := <[ a b c d ]>
      elems |> each !-> tree.insert it, it
      subject := tree.iterator!

    specify 'it responds to #next' !->
      expect( subject ).to.respond-to \next

    describe '#next' !->
      specify 'it maintains alphabetic order' !->
        expect( elems |> map (_) -> subject.next! ).to.eql elems

    describe '#is-done' !->
      specify 'returns false' !->
        expect( subject.is-done! ).to.be.false

    describe 'when it is finished' !->
      before-each !->
        elems |> each (_) -> subject.next!

      describe '#next' !->
        specify 'it throws an error' !->
          expect( !-> subject.next! ).to.throw RangeError

      describe '#is-done' !->
        specify 'it returns true' !->
          expect( subject.is-done! ).to.be.true

    describe 'when it is made out of date' !->
      before-each !->
        tree.insert \e

      specify 'it throws an error' !->
        expect( !-> subject.next! ).to.throw ReferenceError


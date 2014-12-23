var Trie;

Trie = (function() {
  var MATCH_EXACT, MATCH_NONE, MATCH_PREFIX;

  MATCH_EXACT = 2;

  MATCH_PREFIX = 1;

  MATCH_NONE = 0;

  function Trie(words) {
    var word, _i, _len;
    this.tree = {};
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      this.add(word);
    }
  }

  Trie.prototype.add = function(word) {
    var c, subtree, _i, _len;
    subtree = this.tree;
    for (_i = 0, _len = word.length; _i < _len; _i++) {
      c = word[_i];
      if (subtree[c] == null) {
        subtree[c] = {};
      }
      subtree = subtree[c];
    }
    return subtree['$'] = true;
  };

  Trie.prototype.findMatch = function(prefix) {
    var c, subtree, _i, _len;
    prefix = prefix.toLowerCase();
    subtree = this.tree;
    for (_i = 0, _len = prefix.length; _i < _len; _i++) {
      c = prefix[_i];
      if (subtree[c] == null) {
        return MATCH_NONE;
      }
      subtree = subtree[c];
    }
    if (subtree['$'] === true) {
      return MATCH_EXACT;
    } else {
      return MATCH_PREFIX;
    }
  };

  return Trie;

})();

module.exports = Trie;

class Trie
    MATCH_EXACT = 2
    MATCH_PREFIX = 1
    MATCH_NONE = 0

    constructor: (words) ->
        @tree = {}
        for word in words
            @add(word)
    add: (word) ->
        subtree = @tree
        for c in word
            unless subtree[c]?
                subtree[c] = {}
            subtree = subtree[c]
        subtree['$'] = true
    findMatch: (prefix) ->
        prefix = prefix.toLowerCase()
        subtree = @tree
        for c in prefix
            unless subtree[c]?
                return MATCH_NONE
            subtree = subtree[c]
        if subtree['$'] == true
            return MATCH_EXACT
        else
            return MATCH_PREFIX

module.exports = Trie
boardStringToArray = (boardString) ->
    boardString
    .split("\n")
    .map((x) => x.trim())
    .filter((x) => x.length == 10)

filterWordsByBoard = (words, board) ->
    getCharacterCount = (word) =>
        count = {}
        for c in word
            count[c] = 0 unless count[c]?
            count[c] += 1
        count

    getBoardCharacterCount = (board) =>
        count = {}
        for x in [0..board.width-1]
            for y in [0..board.height-1]
                c = board.get([x, y])
                count[c] = 0 unless count[c]?
                count[c] += 1
        count

    boardCount = getBoardCharacterCount(board)
    words.filter (word) =>
        wordCount = getCharacterCount(word.toUpperCase())
        for letter, count of wordCount
            unless boardCount[letter] or boardCount[letter] < count
                return false
        return true

module.exports = {
    boardStringToArray: boardStringToArray,
    filterWordsByBoard: filterWordsByBoard
}
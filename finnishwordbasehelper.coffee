fs = require('fs')

contents = fs.readFileSync('words/kotus/kotus_sanat.txt', 'utf8')
words = contents.split("\n").map((x) => x.trim())


boardString = """
SATVSÄTIAS
SJAOÄMAPUR
RYPRTEKOTA
RAKUKEASEA
AUNIAMUAMU
JEKOPRENUO
VHASOUSKÄR
OTIKUATYTA
TLENADGLAD
EPUEÄNAKIN
ÄNAÄIRERVI
IONUKOÄNOA
AOAEAKUEIN
"""
positionString = """
0000000000
...000.00.
...000.00.
...000.00.
...000.00.
1........0
.1........
.1........
.1........
.1........
.1........
.1........
1111111111
"""

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


class Tri
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
            #console.log "character", c, "Tree:", @tree, "Subtree:", subtree
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


class BoardSolver
    constructor: (@board, @positionBoard, player) ->
        throw "Player should be 0 or 1" unless player == 0 or player == 1
        @player = ''+player
        throw "Board should be defined" unless @board
        throw "PositionBoard should be defined" unless @positionBoard
        unless @board.length == @positionBoard.length
            throw "Board (#{board.length}) and positionBoard (#{positionBoard.length}) should be same length" 
        throw "Board and positionBoard should be same length" unless @board[0].length == @positionBoard[0].length
        @height = @board.length
        @width = @board[0].length
    opposite: (player) ->
        if player == '0'
            player = '1'
        else if player == '1'
            player = '0'
        else
            throw "Invalid player #{player}"
    isPlayer: (c) ->
        c == '0' or c == '1'
    get: (position) ->
        @board[position[1]][position[0]]
    getPosition: (position) ->
        @positionBoard[position[1]][position[0]]
    getPlayerPositions: (player) ->
        positions = []
        for x in [0..@width-1]
            for y in [0..@height-1]
                if @getPosition([x, y]) == player
                    positions.push([x, y])
        positions
    printPositions: (positions) ->
        getCharacter = (pos) =>
            i = 0
            for position in positions
                if position[0] == pos[0] and position[1] == pos[1]
                    return @get(pos)
                    #else
                    #    return '@'
                i += 1
            return '.'
        console.log "Board:"
        console.log positions
        for y in [0..@height-1]
            buf = '  '
            for x in [0..@width-1]
                buf += getCharacter([x, y])
            console.log buf
    evaluate: (positions) ->
        taken = (position) =>
            for takenPosition in position
                if takenPosition[0] == position[0] and takenPosition[1] == position[1]
                    return true
            return false
        score = 0
        #max_score = 0
        for position in positions
            if @isPlayer(@getPosition(position))
                if @getPosition(position) == @opposite(@player)
                    factor = 10
                else
                    factor = 0
            else
                factor = 1
            if @player == '0'
                #max_score = Math.max(max_score, position[1])
                score += position[1]**2 * factor
            else
                #max_score = Math.max(max_score, @height - position[1])
                score += (@height - position[1])**2 * factor
        #score += max_score**4

        return score
    solve: (tri) ->
        startingPositions = ([x, 0] for x in [0..@width-1])
        findNeighbors = (position) =>
            xys = []
            xys.push [position[0]+i, position[1]+j] for i in [-1..1] for j in [-1..1] when not (i == 0 and j == 0)
            xys.filter (o) =>
                0 <= o[0] and o[0] < @width and 0 <= o[1] and o[1] < @height
        filterVisited = (positions, visitedPositions) =>
            positions.filter (position) =>
                for visitedPosition in visitedPositions
                    if visitedPosition[0] == position[0] and visitedPosition[1] == position[1]
                        return false
                return true
        foundWords = []
        recursiveSolve = (word, positions) =>
            lastPosition = positions[positions.length - 1]
            #console.log "last", lastPosition
            character = @get(lastPosition)
            throw "Invalid position #{lastPosition}" unless character
            word = word + character
            match = tri.findMatch(word)
            if match == 0
                #console.log "Could not find anything for", word, positions
                false
            else
                #console.log "Testing ", word, positions
                if match == 2
                    foundWords.push([word, positions, @evaluate(positions)])
                    #console.log "Found word", word, positions
                neighbors = findNeighbors(lastPosition)
                #console.log "neighbors", neighbors
                potentialPositions = filterVisited(neighbors, positions)
                #console.log "potential", potentialPositions
                for potentialPosition in potentialPositions
                    newPositions = positions.slice(0)
                    newPositions.push(potentialPosition)
                    recursiveSolve(word, newPositions)

        for pos in @getPlayerPositions(@player)
            #console.log "Checking out this ",pos," where", @get(pos)
            recursiveSolve('', [pos])

        foundWords.sort (a, b) => b[2] - a[2]
        foundWords.filter (row) =>
            for row2 in foundWords
                if row != row2 and row[0] == row2[0]
                    return false
            return true

        foundWords

board = boardStringToArray(boardString)
positionBoard = boardStringToArray(positionString)

console.log "Game Board:"
console.log board
console.log "Position Board:"
console.log positionBoard

solver = new BoardSolver(board, positionBoard, 0)

console.log "Dictionary", words.length
#words = filterWordsByBoard(words, solver)
console.log "Dictionary (after filtering)", words.length

time_start = Date.now()
tri = new Tri(words)
console.log "Building tri-tree took ",(Date.now() - time_start)/1000," seconds"

foundWords = solver.solve(tri)

for i in [0..2]
    console.log "Solution #{i} is #{foundWords[i][0]} at #{foundWords[i][1][0]}, #{foundWords[i][1][1]}"
    solver.printPositions(foundWords[i][1])
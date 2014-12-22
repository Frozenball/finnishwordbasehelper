fs = require('fs')

contents = fs.readFileSync('words/kotus/kotus_sanat.txt', 'utf8')
words = contents.split("\n").map((x) => x.trim())
board = """
TEANTAEKÄJ
AKRAUTROKI
LOPHTÖNUHN
OIJIATOÖEY
EASPNAHPKÄ
RTEOVNTHSR
PIOKTIÄYIN
AEITRURLYU
JNLIAEOIUV
NOAVTNEKSJ
UTISÄTILAU
YALMIKGPUT
POKURUÄNEK
"""
.split("\n")
.map((x) => x.trim())
.filter((x) => x.length == 10)

class Tri
    MATCH_EXACT = 2
    MATCH_PREFIX = 1
    MATCH_NONE = 0

    constructor: (@words) ->
    findMatch: (prefix) ->
        prefix = prefix.toLowerCase()
        for word in @words
            if word == prefix
                return MATCH_EXACT
            if word[...prefix.length] == prefix
                return MATCH_PREFIX
        return MATCH_NONE


class BoardSolver
    constructor: (@board) ->
        @height = @board.length
        @width = @board[0].length
    get: (position) ->
        @board[position[1]][position[0]]
    solve: (tri) ->
        startingPositions = ([x, @height-1] for x in [0..@width-1])
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
                    foundWords.push([word, positions])
                    console.log "Found word", word, positions
                neighbors = findNeighbors(lastPosition)
                #console.log "neighbors", neighbors
                potentialPositions = filterVisited(neighbors, positions)
                #console.log "potential", potentialPositions
                for potentialPosition in potentialPositions
                    newPositions = positions.slice(0)
                    newPositions.push(potentialPosition)
                    recursiveSolve(word, newPositions)

        console.log "Solving..."
        for pos in startingPositions
            console.log "Checking out this ",pos," where", @get(pos)
            recursiveSolve('', [pos])





console.log "Game Board:"
console.log board
console.log board.length
console.log board[12]


tri = new Tri(words)
solver = new BoardSolver(board)
solver.solve(tri)
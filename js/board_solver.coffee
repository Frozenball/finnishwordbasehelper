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
        @usedWords = []

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

    set: (position, letter) ->
        @board[position[1]][position[0]] = letter

    getPosition: (position) ->
        @positionBoard[position[1]][position[0]]

    setPosition: (position, player) ->
        @positionBoard[position[1]][position[0]] = player
        return true

    getPlayerPositions: (player) ->
        positions = []
        for x in [0..@width-1]
            for y in [0..@height-1]
                if @getPosition([x, y]) == player
                    positions.push([x, y])
        return positions

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
        for y in [0..@height-1]
            buf = '  '
            for x in [0..@width-1]
                buf += getCharacter([x, y])

    evaluate: (positions) ->
        SCORE_VICTORY = 1000000000000

        taken = (position) =>
            for takenPosition in position
                if takenPosition[0] == position[0] and takenPosition[1] == position[1]
                    return true
            return false
        score = 0
        for position in positions
            if @isPlayer(@getPosition(position))
                if @getPosition(position) == @opposite(@player)
                    factor = 100
                else
                    factor = 0
            else
                factor = 1
            if @player == '0'
                score += position[1]**2 * factor
                score += SCORE_VICTORY if position[1] == @height-1
            else
                score += (@height - position[1])**2 * factor
                score += SCORE_VICTORY if position[1] == 0
        return score

    solve: (trie, startingPosition=false) ->
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
            character = @get(lastPosition)
            throw "Invalid position #{lastPosition}" unless character
            word = word + character
            match = trie.findMatch(word)
            if match == 0
                return false
            else
                if match == 2
                    foundWords.push([word, positions, @evaluate(positions)])
                neighbors = findNeighbors(lastPosition)
                potentialPositions = filterVisited(neighbors, positions)
                for potentialPosition in potentialPositions
                    newPositions = positions.slice(0)
                    newPositions.push(potentialPosition)
                    recursiveSolve(word, newPositions)

        if startingPosition
            recursiveSolve('', [startingPosition])
        else
            for pos in @getPlayerPositions(@player)
                recursiveSolve('', [pos])

        foundWords.sort (a, b) => b[2] - a[2]
        foundWords.filter (row) =>
            for word2 in @usedWords
                if row[0] == word2
                    return false
            return true
        foundWords.filter (row) =>
            for row2 in foundWords
                if row != row2 and row[0] == row2[0]
                    return false
            return true

        return foundWords

    useWord: (word) =>
        @usedWords.push(word)

module.exports = BoardSolver
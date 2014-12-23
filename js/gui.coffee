#$ = require('jquery-browserify')
$ = require('jquery')
BoardSolver = require('./board_solver')
Trie = require('./trie')
utils = require('./utils')
LETTERS = 'VOKAALITOOAEEULOKAKAUSIJUTTU'

ALLOW_CHANGES = false
KEY_LEFT = 37
KEY_UP = 38
KEY_RIGHT = 39
KEY_DOWN = 40
KEY_ESCAPE = 27
KEY_COMMA = 188
KEY_DOT = 190

class App
    constructor: ->
        @selected = null
        @width = 10
        @height = 13
        @root = $('.words-root')
        @highlight = []
        
    log: (message) ->
        @root.find('.words-console').append($('
            <div class="note"></div>
        ').text(message))

    init: ->
        @log('Application initialized')
        @initBoard()
        @updateGUI()
        @bind()
        @loadTrie()

    initBoard: ->
        if window.location.hash and window.location.hash[0..1] == '#{'
            data = $.parseJSON(window.location.hash[1..])
            @board = new BoardSolver(data.board, data.positionBoard, parseInt(data.player, 10))
        else
            board = []
            for y in [0..@height-1]
                board.push (LETTERS[Math.round(Math.random() * (LETTERS.length-1))] for x in [0..@width-1])
            positionBoard = []

            positionBoard.push '0000000000'.split('')
            for y in [1..@height-2]
                positionBoard.push '..........'.split('')
            positionBoard.push '1111111111'.split('')
            @board = new BoardSolver(board, positionBoard, 0)
        throw "Root was not found" unless @root[0]

    loadTrie: (callback) ->
        @tri = null
        $.get 'words/kotus/kotus_sanat.txt', (words) =>
            wordCount = words.split("\n").length
            @log("Fetched #{wordCount} words")
            time_start = Date.now()
            @trie = new Trie(words.split("\n").map( (x) => x.trim() ))
            throw "Sanity check 1 failed" unless @trie.findMatch("juust") >= 1
            @log('Trie tree was built on '+((Date.now() - time_start)/1000)+' seconds')
            callback() if callback?

    updateGUI: ->
        @updateLetters()
        @updateButtons()

    updateLetters: ->
        @root.find('.words-letters').empty()
        for y in [0..@height-1]
            for x in [0..@width-1]
                randomLetter = LETTERS[Math.round(Math.random() * (LETTERS.length-1))]
                $letter = $('
                    <div data-x="'+x+'" data-y="'+y+'" class="word-letter"></div>
                ')
                $letter.text(@board.get([x, y]))
                $letter.addClass('player' + @board.getPosition([x, y])) if @board.getPosition([x, y]) != '.'
                if @selected and @selected[0] == x and @selected[1] == y
                    $letter.addClass('selected')
                if utils.inArray(@highlight, [x, y])
                    $letter.addClass('highlight')
                @root.find('.words-letters').append($letter)

    updateButtons: ->
        @root.find('.js-player > span').removeClass('player0').removeClass('player1')
        @root.find('.js-player > span').addClass('player'+@board.player)

        if @selected
            @root.find('.js-find-word').removeClass('disabled')
        else
            @root.find('.js-find-word').addClass('disabled')

    bind: ->
        @root.on 'click', '.word-letter', (e) =>
            e.preventDefault()
            @root.find('.word-letter').removeClass('selected')
            $(e.target).addClass('selected')
            @selected = [$(e.target).data('x'), $(e.target).data('y')]
            @updateGUI()

        @root.on 'click', '.js-find-word', (e) =>
            e.preventDefault()
            @solve(@selected)

        @root.on 'click', '.js-solve', (e) =>
            e.preventDefault()
            @solve()

        @root.on 'click', '.js-player', (e) =>
            e.preventDefault()
            @board.player = @board.opposite(@board.player)
            console.log @board.player
            @updateGUI()

        $('html').keydown (e) =>
            if @selected
                e.preventDefault()
                console.log e.which
                if e.which == KEY_ESCAPE
                    @selected = null
                else if e.which == KEY_UP
                    @selected[1] -= 1
                else if e.which == KEY_DOWN
                    @selected[1] += 1
                else if e.which == KEY_RIGHT
                    @selected[0] += 1
                else if e.which == KEY_LEFT
                    @selected[0] -= 1
                else if e.which == KEY_COMMA
                    @solve(@selected)
                else if e.which == KEY_DOT
                    @solve()
                else
                    c = String.fromCharCode(e.which).toUpperCase()
                    if c == '0'
                        @board.setPosition(@selected, '.')
                    else if c == '1'
                        @board.setPosition(@selected, '0')
                    else if c == '2'
                        @board.setPosition(@selected, '1')
                    else if ALLOW_CHANGES
                        @board.set(@selected, c)
                        @selected[0] += 1

                if @selected[0] >= @width
                    @selected[0] = 0
                    @selected[1] += 1
                if @selected[1] >= @height
                    @selected = [0, 0]
                if @selected[0] < 0
                    @selected[0] = @width-1
                if @selected[1] < 0
                    @selected[1] = @height-1

                @updateHash()
                @updateGUI()

    solve: (startingPosition=false) ->
        throw "Trie tree is not built yet" unless @trie
        foundWords = @board.solve(@trie, startingPosition)
        if foundWords.length >= 1
            @log("Best solution is #{foundWords[0][0]}")
            solutions = foundWords.slice(1, 10).map (x) => x[0]
            @log("Other solutions: "+solutions.join(", "))
            @highlight = foundWords[0][1]
            @updateGUI()
            #@board.useWord(foundWords[0][0])
            #for pos in foundWords[0][1]
            #    @board.setPosition(pos, ''+@board.player)
            #@board.player = ''+@board.opposite(@board.player)
        else
            @log("No solution was found. ")

    updateHash: ->
        window.location.hash = JSON.stringify({
            board: @board.board,
            player: @board.player,
            positionBoard: @board.positionBoard
        })
        true


init = ->
    console.log "asd"
    $ =>
        app = new App()
        app.init()

module.exports = {
    init: init
}
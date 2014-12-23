#$ = require('jquery-browserify')
$ = require('jquery')
BoardSolver = require('./board_solver')
Trie = require('./trie')
utils = require('./utils')
LETTERS = 'VOKAALITOOAEEULOKAKAUSIJUTTU'

class App
    constructor: ->
        @selected = null
        @width = 10
        @height = 13
        @root = $('.words-root')

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
        
    log: (message) ->
        @root.find('.words-console').append($('
            <div class="note"></div>
        ').text(message))

    init: ->
        @log('Application initialized')
        @initLetters()
        @bind()
        @loadTrie()

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

    initLetters: ->
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
                @root.find('.words-letters').append($letter)

    bind: ->
        @root.on 'click', '.word-letter', (e) =>
            @root.find('.word-letter').removeClass('selected')
            $(e.target).addClass('selected')
            @selected = [$(e.target).data('x'), $(e.target).data('y')]
        @root.on 'click', '.js-solve', (e) =>
            @solve()
        $('html').keypress (e) =>
            if @selected
                c = String.fromCharCode(e.which).toUpperCase()

                if c == '0'
                    @board.setPosition(@selected, '.')
                else if c == '1'
                    @board.setPosition(@selected, '0')
                else if c == '2'
                    @board.setPosition(@selected, '1')
                else
                    @board.set(@selected, c)
                    @selected[0] += 1
                    if @selected[0] >= @width
                        @selected[0] = 0
                        @selected[1] += 1
                    if @selected[1] >= @height
                        @selected = [0, 0]
                @updateHash()
                @initLetters()

    solve: ->
        throw "Trie tree is not built yet" unless @trie
        foundWords = @board.solve(@trie)
        if foundWords.length >= 1
            @log("Best solution is #{foundWords[0][0]}")
            solutions = foundWords.slice(1, 10).map (x) => x[0]
            @log("Other solutions: "+solutions.join(", "))
            #@board.useWord(foundWords[0][0])
            #for pos in foundWords[0][1]
            #    @board.setPosition(pos, ''+@board.player)
            #@initLetters()
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
var $, App, BoardSolver, LETTERS, Trie, init, utils;

$ = require('jquery');

BoardSolver = require('./board_solver');

Trie = require('./trie');

utils = require('./utils');

LETTERS = 'VOKAALITOOAEEULOKAKAUSIJUTTU';

App = (function() {
  function App() {
    var board, data, positionBoard, x, y, _i, _j, _ref, _ref1;
    this.selected = null;
    this.width = 10;
    this.height = 13;
    this.root = $('.words-root');
    if (window.location.hash && window.location.hash.slice(0, 2) === '#{') {
      data = $.parseJSON(window.location.hash.slice(1));
      this.board = new BoardSolver(data.board, data.positionBoard, parseInt(data.player, 10));
    } else {
      board = [];
      for (y = _i = 0, _ref = this.height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
        board.push((function() {
          var _j, _ref1, _results;
          _results = [];
          for (x = _j = 0, _ref1 = this.width - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
            _results.push(LETTERS[Math.round(Math.random() * (LETTERS.length - 1))]);
          }
          return _results;
        }).call(this));
      }
      positionBoard = [];
      positionBoard.push('0000000000'.split(''));
      for (y = _j = 1, _ref1 = this.height - 2; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 1 <= _ref1 ? ++_j : --_j) {
        positionBoard.push('..........'.split(''));
      }
      positionBoard.push('1111111111'.split(''));
      this.board = new BoardSolver(board, positionBoard, 0);
    }
    if (!this.root[0]) {
      throw "Root was not found";
    }
  }

  App.prototype.log = function(message) {
    return this.root.find('.words-console').append($('<div class="note"></div>').text(message));
  };

  App.prototype.init = function() {
    this.log('Application initialized');
    this.initLetters();
    this.bind();
    return this.loadTrie();
  };

  App.prototype.loadTrie = function(callback) {
    this.tri = null;
    return $.get('words/kotus/kotus_sanat.txt', (function(_this) {
      return function(words) {
        var time_start, wordCount;
        wordCount = words.split("\n").length;
        _this.log("Fetched " + wordCount + " words");
        time_start = Date.now();
        _this.trie = new Trie(words.split("\n").map(function(x) {
          return x.trim();
        }));
        if (!(_this.trie.findMatch("juust") >= 1)) {
          throw "Sanity check 1 failed";
        }
        _this.log('Trie tree was built on ' + ((Date.now() - time_start) / 1000) + ' seconds');
        if (callback != null) {
          return callback();
        }
      };
    })(this));
  };

  App.prototype.initLetters = function() {
    var $letter, randomLetter, x, y, _i, _ref, _results;
    this.root.find('.words-letters').empty();
    _results = [];
    for (y = _i = 0, _ref = this.height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
      _results.push((function() {
        var _j, _ref1, _results1;
        _results1 = [];
        for (x = _j = 0, _ref1 = this.width - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
          randomLetter = LETTERS[Math.round(Math.random() * (LETTERS.length - 1))];
          $letter = $('<div data-x="' + x + '" data-y="' + y + '" class="word-letter"></div>');
          $letter.text(this.board.get([x, y]));
          if (this.board.getPosition([x, y]) !== '.') {
            $letter.addClass('player' + this.board.getPosition([x, y]));
          }
          if (this.selected && this.selected[0] === x && this.selected[1] === y) {
            $letter.addClass('selected');
          }
          _results1.push(this.root.find('.words-letters').append($letter));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  App.prototype.bind = function() {
    this.root.on('click', '.word-letter', (function(_this) {
      return function(e) {
        _this.root.find('.word-letter').removeClass('selected');
        $(e.target).addClass('selected');
        return _this.selected = [$(e.target).data('x'), $(e.target).data('y')];
      };
    })(this));
    this.root.on('click', '.js-solve', (function(_this) {
      return function(e) {
        return _this.solve();
      };
    })(this));
    return $('html').keypress((function(_this) {
      return function(e) {
        var c;
        if (_this.selected) {
          c = String.fromCharCode(e.which).toUpperCase();
          if (c === '0') {
            _this.board.setPosition(_this.selected, '.');
          } else if (c === '1') {
            _this.board.setPosition(_this.selected, '0');
          } else if (c === '2') {
            _this.board.setPosition(_this.selected, '1');
          } else {
            _this.board.set(_this.selected, c);
            _this.selected[0] += 1;
            if (_this.selected[0] >= _this.width) {
              _this.selected[0] = 0;
              _this.selected[1] += 1;
            }
            if (_this.selected[1] >= _this.height) {
              _this.selected = [0, 0];
            }
          }
          _this.updateHash();
          return _this.initLetters();
        }
      };
    })(this));
  };

  App.prototype.solve = function() {
    var foundWords, solutions;
    if (!this.trie) {
      throw "Trie tree is not built yet";
    }
    foundWords = this.board.solve(this.trie);
    if (foundWords.length >= 1) {
      this.log("Best solution is " + foundWords[0][0]);
      solutions = foundWords.slice(1, 10).map((function(_this) {
        return function(x) {
          return x[0];
        };
      })(this));
      return this.log("Other solutions: " + solutions.join(", "));
    } else {
      return this.log("No solution was found. ");
    }
  };

  App.prototype.updateHash = function() {
    window.location.hash = JSON.stringify({
      board: this.board.board,
      player: this.board.player,
      positionBoard: this.board.positionBoard
    });
    return true;
  };

  return App;

})();

init = function() {
  console.log("asd");
  return $((function(_this) {
    return function() {
      var app;
      app = new App();
      return app.init();
    };
  })(this));
};

module.exports = {
  init: init
};

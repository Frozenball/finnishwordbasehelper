// Generated by CoffeeScript 1.8.0
(function() {
  var BoardSolver, Tri, board, contents, fs, solver, tri, words;

  fs = require('fs');

  contents = fs.readFileSync('words/kotus/kotus_sanat.txt', 'utf8');

  words = contents.split("\n").map((function(_this) {
    return function(x) {
      return x.trim();
    };
  })(this));

  board = "TEANTAEKÄJ\nAKRAUTROKI\nLOPHTÖNUHN\nOIJIATOÖEY\nEASPNAHPKÄ\nRTEOVNTHSR\nPIOKTIÄYIN\nAEITRURLYU\nJNLIAEOIUV\nNOAVTNEKSJ\nUTISÄTILAU\nYALMIKGPUT\nPOKURUÄNEK".split("\n").map((function(_this) {
    return function(x) {
      return x.trim();
    };
  })(this)).filter((function(_this) {
    return function(x) {
      return x.length === 10;
    };
  })(this));

  Tri = (function() {
    var MATCH_EXACT, MATCH_NONE, MATCH_PREFIX;

    MATCH_EXACT = 2;

    MATCH_PREFIX = 1;

    MATCH_NONE = 0;

    function Tri(words) {
      this.words = words;
    }

    Tri.prototype.findMatch = function(prefix) {
      var word, _i, _len, _ref;
      prefix = prefix.toLowerCase();
      _ref = this.words;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        word = _ref[_i];
        if (word === prefix) {
          return MATCH_EXACT;
        }
        if (word.slice(0, prefix.length) === prefix) {
          return MATCH_PREFIX;
        }
      }
      return MATCH_NONE;
    };

    return Tri;

  })();

  BoardSolver = (function() {
    function BoardSolver(board) {
      this.board = board;
      this.height = this.board.length;
      this.width = this.board[0].length;
    }

    BoardSolver.prototype.get = function(position) {
      return this.board[position[0]][position[1]];
    };

    BoardSolver.prototype.solve = function(tri) {
      var filterVisited, findNeighbors, foundWords, pos, recursiveSolve, startingPositions, y, _i, _len, _results;
      startingPositions = (function() {
        var _i, _ref, _results;
        _results = [];
        for (y = _i = 0, _ref = this.height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
          _results.push([this.width - 1, y]);
        }
        return _results;
      }).call(this);
      findNeighbors = (function(_this) {
        return function(position) {
          var i, j, xys, _i, _j;
          xys = [];
          for (j = _i = -1; _i <= 1; j = ++_i) {
            if (!(i === 0 && j === 0)) {
              for (i = _j = -1; _j <= 1; i = ++_j) {
                xys.push([position[0] + i, position[1] + j]);
              }
            }
          }
          return xys.filter(function(o) {
            return 0 <= o[0] && o[0] < _this.width && 0 <= o[1] && o[1] < _this.height;
          });
        };
      })(this);
      filterVisited = (function(_this) {
        return function(positions, visitedPositions) {
          return positions.filter(function(position) {
            var visitedPosition, _i, _len;
            for (_i = 0, _len = visitedPositions.length; _i < _len; _i++) {
              visitedPosition = visitedPositions[_i];
              if (visitedPosition[0] === position[0] && visitedPosition[1] === position[1]) {
                return false;
              }
            }
            return true;
          });
        };
      })(this);
      foundWords = [];
      recursiveSolve = (function(_this) {
        return function(word, positions) {
          var character, lastPosition, match, neighbors, newPositions, potentialPosition, potentialPositions, _i, _len, _results;
          lastPosition = positions[positions.length - 1];
          character = _this.get(lastPosition);
          word = word + character;
          match = tri.findMatch(word);
          if (match === 0) {
            return false;
          } else {
            if (match === 2) {
              foundWords.push([word, positions]);
              console.log("Found word", word, positions);
            }
            neighbors = findNeighbors(lastPosition);
            potentialPositions = filterVisited(neighbors, positions);
            _results = [];
            for (_i = 0, _len = potentialPositions.length; _i < _len; _i++) {
              potentialPosition = potentialPositions[_i];
              newPositions = positions.splice(0);
              newPositions.push(potentialPosition);
              _results.push(recursiveSolve(word, newPositions));
            }
            return _results;
          }
        };
      })(this);
      console.log("Solving...");
      _results = [];
      for (_i = 0, _len = startingPositions.length; _i < _len; _i++) {
        pos = startingPositions[_i];
        console.log("Checking out this ", pos);
        _results.push(recursiveSolve('', [pos]));
      }
      return _results;
    };

    return BoardSolver;

  })();

  console.log("Game Board:");

  console.log(board);

  tri = new Tri(words);

  solver = new BoardSolver(board);

  solver.solve(tri);

}).call(this);

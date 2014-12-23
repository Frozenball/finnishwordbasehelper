var BoardSolver,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

BoardSolver = (function() {
  function BoardSolver(board, positionBoard, player) {
    this.board = board;
    this.positionBoard = positionBoard;
    this.useWord = __bind(this.useWord, this);
    if (!(player === 0 || player === 1)) {
      throw "Player should be 0 or 1";
    }
    this.player = '' + player;
    if (!this.board) {
      throw "Board should be defined";
    }
    if (!this.positionBoard) {
      throw "PositionBoard should be defined";
    }
    if (this.board.length !== this.positionBoard.length) {
      throw "Board (" + board.length + ") and positionBoard (" + positionBoard.length + ") should be same length";
    }
    if (this.board[0].length !== this.positionBoard[0].length) {
      throw "Board and positionBoard should be same length";
    }
    this.height = this.board.length;
    this.width = this.board[0].length;
    this.usedWords = [];
  }

  BoardSolver.prototype.opposite = function(player) {
    if (player === '0') {
      return player = '1';
    } else if (player === '1') {
      return player = '0';
    } else {
      throw "Invalid player " + player;
    }
  };

  BoardSolver.prototype.isPlayer = function(c) {
    return c === '0' || c === '1';
  };

  BoardSolver.prototype.get = function(position) {
    return this.board[position[1]][position[0]];
  };

  BoardSolver.prototype.set = function(position, letter) {
    return this.board[position[1]][position[0]] = letter;
  };

  BoardSolver.prototype.getPosition = function(position) {
    return this.positionBoard[position[1]][position[0]];
  };

  BoardSolver.prototype.setPosition = function(position, player) {
    this.positionBoard[position[1]][position[0]] = player;
    return true;
  };

  BoardSolver.prototype.getPlayerPositions = function(player) {
    var positions, x, y, _i, _j, _ref, _ref1;
    positions = [];
    for (x = _i = 0, _ref = this.width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
      for (y = _j = 0, _ref1 = this.height - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
        if (this.getPosition([x, y]) === player) {
          positions.push([x, y]);
        }
      }
    }
    return positions;
  };

  BoardSolver.prototype.printPositions = function(positions) {
    var buf, getCharacter, x, y, _i, _ref, _results;
    getCharacter = (function(_this) {
      return function(pos) {
        var i, position, _i, _len;
        i = 0;
        for (_i = 0, _len = positions.length; _i < _len; _i++) {
          position = positions[_i];
          if (position[0] === pos[0] && position[1] === pos[1]) {
            return _this.get(pos);
          }
          i += 1;
        }
        return '.';
      };
    })(this);
    _results = [];
    for (y = _i = 0, _ref = this.height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
      buf = '  ';
      _results.push((function() {
        var _j, _ref1, _results1;
        _results1 = [];
        for (x = _j = 0, _ref1 = this.width - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
          _results1.push(buf += getCharacter([x, y]));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  BoardSolver.prototype.evaluate = function(positions) {
    var factor, position, score, taken, _i, _len;
    taken = (function(_this) {
      return function(position) {
        var takenPosition, _i, _len;
        for (_i = 0, _len = position.length; _i < _len; _i++) {
          takenPosition = position[_i];
          if (takenPosition[0] === position[0] && takenPosition[1] === position[1]) {
            return true;
          }
        }
        return false;
      };
    })(this);
    score = 0;
    for (_i = 0, _len = positions.length; _i < _len; _i++) {
      position = positions[_i];
      if (this.isPlayer(this.getPosition(position))) {
        if (this.getPosition(position) === this.opposite(this.player)) {
          factor = 100;
        } else {
          factor = 0;
        }
      } else {
        factor = 1;
      }
      if (this.player === '0') {
        score += Math.pow(position[1], 2) * factor;
      } else {
        score += Math.pow(this.height - position[1], 2) * factor;
      }
    }
    return score;
  };

  BoardSolver.prototype.solve = function(trie) {
    var filterVisited, findNeighbors, foundWords, pos, recursiveSolve, _i, _len, _ref;
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
        if (!character) {
          throw "Invalid position " + lastPosition;
        }
        word = word + character;
        match = trie.findMatch(word);
        if (match === 0) {
          return false;
        } else {
          if (match === 2) {
            foundWords.push([word, positions, _this.evaluate(positions)]);
          }
          neighbors = findNeighbors(lastPosition);
          potentialPositions = filterVisited(neighbors, positions);
          _results = [];
          for (_i = 0, _len = potentialPositions.length; _i < _len; _i++) {
            potentialPosition = potentialPositions[_i];
            newPositions = positions.slice(0);
            newPositions.push(potentialPosition);
            _results.push(recursiveSolve(word, newPositions));
          }
          return _results;
        }
      };
    })(this);
    _ref = this.getPlayerPositions(this.player);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      pos = _ref[_i];
      recursiveSolve('', [pos]);
    }
    foundWords.sort((function(_this) {
      return function(a, b) {
        return b[2] - a[2];
      };
    })(this));
    foundWords.filter((function(_this) {
      return function(row) {
        var word2, _j, _len1, _ref1;
        _ref1 = _this.usedWords;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          word2 = _ref1[_j];
          if (row[0] === word2) {
            return false;
          }
        }
        return true;
      };
    })(this));
    foundWords.filter((function(_this) {
      return function(row) {
        var row2, _j, _len1;
        for (_j = 0, _len1 = foundWords.length; _j < _len1; _j++) {
          row2 = foundWords[_j];
          if (row !== row2 && row[0] === row2[0]) {
            return false;
          }
        }
        return true;
      };
    })(this));
    return foundWords;
  };

  BoardSolver.prototype.useWord = function(word) {
    console.log(this.usedWords);
    return this.usedWords.push(word);
  };

  return BoardSolver;

})();

module.exports = BoardSolver;

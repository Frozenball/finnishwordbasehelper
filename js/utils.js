var boardStringToArray, equals, filterWordsByBoard, inArray;

equals = function(arr1, arr2) {
  var i, _i, _ref;
  if (arr1.length !== arr2.length) {
    return false;
  }
  for (i = _i = 0, _ref = arr1.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
    if (arr1[i] !== arr2[i]) {
      return false;
    }
  }
  return true;
};

inArray = function(array, value) {
  var each, _i, _len;
  for (_i = 0, _len = array.length; _i < _len; _i++) {
    each = array[_i];
    if (equals(each, value)) {
      return true;
    }
  }
  return false;
};

boardStringToArray = function(boardString) {
  return boardString.split("\n").map((function(_this) {
    return function(x) {
      return x.trim();
    };
  })(this)).filter((function(_this) {
    return function(x) {
      return x.length === 10;
    };
  })(this));
};

filterWordsByBoard = function(words, board) {
  var boardCount, getBoardCharacterCount, getCharacterCount;
  getCharacterCount = (function(_this) {
    return function(word) {
      var c, count, _i, _len;
      count = {};
      for (_i = 0, _len = word.length; _i < _len; _i++) {
        c = word[_i];
        if (count[c] == null) {
          count[c] = 0;
        }
        count[c] += 1;
      }
      return count;
    };
  })(this);
  getBoardCharacterCount = (function(_this) {
    return function(board) {
      var c, count, x, y, _i, _j, _ref, _ref1;
      count = {};
      for (x = _i = 0, _ref = board.width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        for (y = _j = 0, _ref1 = board.height - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
          c = board.get([x, y]);
          if (count[c] == null) {
            count[c] = 0;
          }
          count[c] += 1;
        }
      }
      return count;
    };
  })(this);
  boardCount = getBoardCharacterCount(board);
  return words.filter((function(_this) {
    return function(word) {
      var count, letter, wordCount;
      wordCount = getCharacterCount(word.toUpperCase());
      for (letter in wordCount) {
        count = wordCount[letter];
        if (!(boardCount[letter] || boardCount[letter] < count)) {
          return false;
        }
      }
      return true;
    };
  })(this));
};

module.exports = {
  boardStringToArray: boardStringToArray,
  filterWordsByBoard: filterWordsByBoard,
  inArray: inArray,
  equals: equals
};

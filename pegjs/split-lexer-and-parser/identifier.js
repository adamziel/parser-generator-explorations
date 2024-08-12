module.exports = {
    determineNumericType(text) {
      // This is a simplified version of the original ANTLR action
      // and may not cover all edge cases.
      if (text.length > 10) {
        return 'LONG_NUMBER';
      }
      return 'INT_NUMBER';
    },
  
    determineFunction(symbol) {
      return symbol; // In this simplified version, we just return the symbol
    },
};

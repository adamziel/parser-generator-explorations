// const l = require('./peggy_lexer.js');
// console.log(l.parse('SELECT 1'));

const p = require('./peg_parser.js');
// const p = require('./peggy_parser.js');
console.log(p.parse(['SELECT_SYMBOL', 'IDENTIFIER', 'SEMICOLON_SYMBOL'].join('')));
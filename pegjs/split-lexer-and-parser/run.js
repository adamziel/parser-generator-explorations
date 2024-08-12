// const l = require('./peggy_lexer.js');
// console.log(l.parse('SELECT 1'));

// const p = require('./peg_parser.js');
const p = require('./peggy_parser.js');
const ast = p.parse([
    'SELECT_SYMBOL',
    'IDENTIFIER',
    'COMMA_SYMBOL',
    "b'101'",
    'COMMA_SYMBOL',
    'NUMBER_SYMBOL',
    'FROM_SYMBOL',
    'IDENTIFIER',
    'SEMICOLON_SYMBOL'
].join(''));
console.log(JSON.stringify(ast, null, 2));
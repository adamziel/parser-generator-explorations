
// parse a bnf or ebnf string grammar

var fs = require('fs');
var grammar = fs.readFileSync('MySQLParser.ebnf', 'utf8');

var ebnfParser = require('ebnf-parser');
const parsed = ebnfParser.parse(grammar);
console.log(parsed);

// const jison = ebnfParser.transform(parsed.bnf);
// console.log(jison)

import { Grammars, Parser } from 'ebnf';
import fs from 'fs';

let grammar = fs.readFileSync('MySQLFull.ebnf', 'utf8');
// let grammar = fs.readFileSync('MySQLLexer.ebnf', 'utf8');
// console.log(Grammars)
let RULES = Grammars.W3C.getRules(grammar);
// console.log(RULES);
// This doesn't lead to infinite recursion, but it's not far off!
let parser = new Parser(RULES, { debug: true });
// const ast = parser.getAST('SELECT*FROM`a`');
import * as syntax from "./program.js";

const program    = syntax.Parse_Program("aabbaabab").root;
const chunk   = program.value[0];
const firstBs = program.value[1];
console.log(chunk.value)
// SyntaxNode<a> SyntaxNode<a>

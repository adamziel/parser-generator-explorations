Explores the bnf-parser package to convert the MySQL BNF grammar to a WebAssembly parser.

https://www.npmjs.com/package/bnf-parser

Run as follows:

```
npm install
node ./node_modules/bnf-parser/bin/compile.js ./
mkdir node_modules/.bin/artifacts
cp ./shared* ./node_modules/.bin/artifacts
node ./node_modules/bnf-parser/bin/cli.js ./
```

The idea is nice, but it creates a node for each character :(

```ts
const program    = syntax.Parse_Program("aabbaabab").root;
const chunk   = program.value[0];
const firstBs = program.value[1];
console.log(chunk.value[0].value[0].value)
// SyntaxNode<a> SyntaxNode<a>
```

Also, it doesn't like the MySQL.bnf grammar file. If we could use WASM in PHP, I'd consider exploring this further, but we can't so that's it.

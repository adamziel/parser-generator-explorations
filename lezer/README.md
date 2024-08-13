
If there are no problems with the grammar specified in lang.grammar, this will write two files, lang.js and lang.terms.js.

The first is the main grammar file. It depends on @lezer/lr and on any files specified in external token or other external declarations. It exports a binding parser that holds an LRParser instance.

The terms file contains, for every external token and every rule that either is a tree node and doesn't have parameters, or has the @export pseudo-prop, an export with the same name as the term that holds the term's ID. When you define an external tokenizer, you'll usually need to import the token IDs for the tokens you want to recognize from this file. (Since there'll be quite a lot of definitions in the file for regular-sized grammars, you might want to use a tree-shaking bundler to remove the ones you do not need.)

```
npm install
bunx lezer-generator lang.grammar -o lang.js
esbuild --bundle basic.js > dist/bundle.js
```

Downside:

* It generates a state table that seems difficult to translate to PHP:
  `!WQYQPOOOhQPO'#CdOOQO'#Ci'#CiOOQO'#Ce'#CeQYQPOOOOQO,59O,59OOyQPO,59OOOQO-E6c-E6cOOQO1G.j1G.j`

Upside:

* Is fast!
* Generates an AST
* The resulting parser is small
* Has "skip whitespace" semantics!
* Could largely be transpiled by an automated JS -> PHP tool
* The grammar resembles EBNF form and support custom callbacks
* The resulting parser is quite small and could potentially be translated to PHP with AI or another automated tool.

TODO:

* Case-insensitive token matching (e.g. select, SELECT selECT)
  * Explanation on how to do it: https://discuss.codemirror.net/t/case-insensitive-lang-support/4907/2
  * Code example: https://github.com/lezer-parser/php/blob/main/src/php.grammar#L425

Problem: Running out of memory when generating the parser from mysql.grammar.

Solution: Increase the heap size

```
# Via exports
export NODE_OPTIONS=--max_old_space_size=10096
npx lezer-generator mysql.grammar -o mysql.js

# Or via CLI options
node --max-old-space-size=8192 index.js
```

Problem: Parser generation takes 10+ minutes

Solution: Just accept it. It's a one-time operation. Better to have a slow parser generator than a slow parser.

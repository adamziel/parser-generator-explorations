This is an attempt to convert the MySQLParser.ebnf grammar to a Jison grammar.

No-go: [Jison doesn't output an AST, only a flat list](https://stackoverflow.com/questions/8467150/how-to-get-abstract-syntax-tree-ast-out-of-jison-parser).

Building an AST requires embedding the logic in the grammar - that's a lot of work!

Here's a JSON parsing example:

```
object
    : '{' pair_list '}' { $$ = {}; for (var i = 0; i < $2.length; i++) { $$[$2[i].key] = $2[i].value; } }
    ;
```

Nah, we need something that can understand the grammar and generate an AST for us.
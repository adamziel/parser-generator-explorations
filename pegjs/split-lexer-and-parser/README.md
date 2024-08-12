This is a failed attempt to generate a separate PEGJS parser and lexer.

Why split them?

Because then we can use an efficient tokenizer that doesn't go character by character.

Unfortunately, PEG.js seems to require a "root parsing rule" and then the generated parser reasons about the parsed structure right away.

It may be still possible to separate the lexer and parser using either a crafty set of CLI options or by modifying the generated parser. We may need that eventually, but for now I'll go with the single parser approach and see how far it gets us.

Inspect and run `run.js` to see the generated parser in action.
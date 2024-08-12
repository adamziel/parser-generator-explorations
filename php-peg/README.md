PHP PEG explorations

It produces a Packrat / recursive descent parser.

On the upside, it has whitespace skipping semantics built in.

On the downside, the result isn't really AST but a nested array of tokens. Also, the included
Calculator example doesn't seem to correclty process math expressions.

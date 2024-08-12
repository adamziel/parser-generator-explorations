This is a failed attempt to generate a PEGJS parser+lexer in one go
using a joint grammar.

Unfortunately, something seems to have been lost in translation
and we're getting a faulty AST. It's extremely difficult to debug, 
because PEG.js doesn't provide the rule names in the AST.

Even with peggy.js and a custom tracer, it's still hard to see what's 
going on.

Therefore, I'm abandoning this approach and will try to generate
a parser that provides better debugging tools.
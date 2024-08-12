This is a failed attempt to generate a PEGJS parser+lexer in one go
using a joint grammar.

Unfortunately, something seems to have been lost in translation
and we're getting a faulty AST. It's extremely difficult to debug, 
because PEG.js doesn't provide the rule names in the AST.

Even with peggy.js and a custom tracer, it's still hard to see what's 
going on.

Therefore, I'm abandoning this approach and will try to generate
a parser that provides better debugging tools.

Oh, it's even worse! PEG.js doesn't properly tokenize the input. This means
that `SELECT 12 FROM` is ambiguous with `SELECT 12F` because the generated
parser won't realize `FROM` is an identifier.

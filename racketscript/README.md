Racket is a language-orienged language, and Racketscript is a Racket to JavaScript compiler. This exploration is about using Racketscript to generate a MySQL parser.

Code example sourced from https://gist.github.com/danking/1068185

Downsides:

* Racketscript isn't dependency-free.
* I couldn't get it to run in http://play.racketscript.org/ because of parser-tools dependency (lex.rkt.js net::ERR_ABORTED 404 (Not Found))

It smells like a large bundle size and a difficult JS -> PHP translation. Let's abandon this for now.

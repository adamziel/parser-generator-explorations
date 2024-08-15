## EBNF -> PHP Parser

This is an exploration of converting an ENBF-based grammar to a PHP parser.

Tl;dr we did it. The parser is in `parser/DynamicRecursiveDescentParser.php`. Beyond MySQL queries it can be used with any EBNF grammar whatsoever. We could parse JSON, XML, or any other language that can be described by an EBNF grammar.

### Grammar factoring

This section relates to the scripts in the `grammar-factoring` subdirectory.

The steps are as follows

1. Convert [MySQLParser.g4](https://github.com/mysql/mysql-workbench/blob/8.0/library/parsers/grammars/MySQLParser.g4) to (MySQLParser.ebnf using the [grammar-converter](https://github.com/vorpal-research/grammar-converter/tree/master) project.
2. Convert MySQLParser.ebnf to MySQLParser.json using the [node-ebnf](https://github.com/lys-lang/node-ebnf) package. This already factors compound rules into separate rules, e.g. `query ::= SELECT (ALL | DISTINCT)` becomes `query ::= select %select_fragment0` and `%select_fragment0 ::= ALL | DISTINCT`.
3. Expand `*`, `+`, `?` into modifiers into separate, right-recursive rules. For example, `columns ::= column (',' column)*` becomes `columns ::= column columns_rr` and `columns_rr ::= ',' column | ε`.
4. Factor left-recursion from the grammar and replace it with right recursion. For example, `expr ::= expr '+' expr | number | ID` becomes `expr ::= number expr_rr` and `expr_rr ::= '+' number | ε`.
5. Convert the grammar into a PHP file that can be `require`d by the PHP parser.

To regenerate the grammar from the EBNF file (so only steps 2-5), run the `create_grammar.sh` script.

### Parser

The parser is in `parser/DynamicRecursiveDescentParser.php` file that you can execute directly:

```sh
php DynamicRecursiveDescentParser.php
```

It is astonishingly simple. The `parse()` method has just 50 lines of code. All the parsing rules are provided by the grammar.

#### Challenge #1: Size

The grammar file is 1.2MB large (100kb gzipped). This already is a "compressed" form where all rules and tokens are encoded as integers.

I see two ways to reduce the size:

1. Explore further factorings of the grammar. Run left factoring to deduplicate any ambigous rules, then extract `AB|AC|AD` into `A(B|C|D)` etc.
2. Let go of parts of the grammar. We could modularize it as needed and only load the parts we use. For example, most of the time we won't need anything related to `CREATE PROCEDURE`, `GRANT PRIVILIGES`, or `DROP INDEX`. We could load these only when needed.
3. Collapse some tokens into the same token. Perhaps we don't need the same granularity as the original grammar.

#### Challenge #2: Speed

The parser can handle about 50 complex SELECT queries per second on a MacBook pro. We need to do better than that.

First, we need to profile and see where most of the time is spent. I suspect it's backtracking – the parser tries matching all the rules in the current branch and trashes the results if it fails.

Here's a few optimization ideas:

* Translate the largest and common lookups into a PHP switch statement. This would take more bytes on the disk but could be faster to execute.
* Precompute the first `TOKEN => RULE[]` set for each rule and use it to replace a costly iterative search with a cheap hash lookup. If we manage to do this, we might also be able to switch to a LALR(1) parser.

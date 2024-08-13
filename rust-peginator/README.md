Explorations of the [Peginator parser generator](https://github.com/badicsalex/peginator).

### Upsides:

* Uses EBNF syntax that we already have for MySQL.
* By default, peginator will skip ASCII whitespaces before every rule match, field, override, literal, character range or end of input match.

### How to use:

The README doesn't say that explicitly, but there's a `peginator-cli` binary that can be used to generate a parser from an EBNF file.

```sh
cargo install peginator-cli
peginator-cli ./src/test-grammar.peginator > src/test-parser.rs
peginator-cli ./src/mysql.peginator > src/mysql_parser.rs
```

To run the generated parser:

```sh
cargo fmt
cargo build
cargo run
```
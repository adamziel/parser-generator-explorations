This explores the LALRPOP parser generator for Rust.

On the downside, it uses a state table which makes manual parser modifications difficult.

On the upside, it [can generate an AST](https://lalrpop.github.io/lalrpop/tutorial/005_building_asts.html).

On the downside, it requires a separate ast.rs file that explicitly declares possible AST nodes
and maps all the grammar rules to them. I'm not saying no to that, but it's a lot of work so I'm
putting it on hold for now.

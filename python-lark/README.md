Python's Lark explorations

Run demo parsers:

```sh
python lark_hello_world.py
python lark_json.py
```

Generate a static parser from a .lark file ([.lark file example](https://github.com/lark-parser/lark/blob/master/lark/grammars/common.lark)):

```sh
python -m lark.tools.standalone json.lark
```

Resources:

* Lark grammars library: https://github.com/ligurio/lark-grammars/tree/master/lark_grammars/grammars
* SQLite .lark grammar: https://github.com/ligurio/lark-grammars/blob/master/lark_grammars/grammars/sqlite.lark

On the plus:

* Output code is dependency-free and GPT may potentially be able to convert it to PHP.
* The resulting parser is fast!
* There is a JavaScript port: https://pypi.org/project/lark-js/

On the minus:

* The standalone code is very dynamic and uses python features that may be difficult to convert to PHP, 
  especially using AI.
* It generates a state table, similarly to ANTLR, which makes manual parser modifications extremely difficult.
* It has troubles understanding grammar symbols like "/" or "*", which makes parsing block comments challenging. Sometimes it's also difficult to encode those symbols in regular expressions.

Lark doesn't seem to handle ambiguity very well, e.g. I got dozens of errors like
this one when trying to parse the MySQL grammar:


Reduce/Reduce collision in Terminal('SEMICOLON') between the following rules: 
      - <identifier_keywords_ambiguous2_labels : >
      - <identifier_keywords_ambiguous3_roles : >
      - <role_or_identifier_keyword : >
      - <identifier_keywords_ambiguous1_roles_and_labels : >
      - <symbol_identifier : >
      - <identifier_keyword : >
      - <pure_identifier : >
      - <identifier_keywords_ambiguous4_system_variables : >
      - <identifier : >
      - <label_keyword : >
      - <role_or_label_keyword : >
      - <identifier_keywords_unambiguous : >
      - <symbol_master_heartbeat_period_symbol : >


[The explanation on GitHub](https://github.com/lark-parser/lark/issues/182) makes sense, but I'm not sure how it applies to the grammar we're using.

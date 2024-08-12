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

On the plus:

* Output code is dependency-free and GPT may potentially be able to convert it to PHP.
* The resulting parser is fast!

On the minus:

* The standalone code is very dynamic and uses python features that may be difficult to convert to PHP, 
  especially using AI.
  
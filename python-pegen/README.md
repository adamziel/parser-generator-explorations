Python's pegen looked promising:

https://github.com/we-like-parsers/pegen

However, it failed to parse our MySQL grammar:

```sh
python -m pegen mysql.ebnf -o mysql_parser.py
# RecursionError: maximum recursion depth exceeded
```

Bummer!

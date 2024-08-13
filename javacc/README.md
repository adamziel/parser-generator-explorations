Evaluating [JavaCC](https://javacc.github.io/javacc), the most popular parser generator for use with Java applications.

Examples:

https://javacc.github.io/javacc/tutorials/examples.html

Setup:

```bash
docker build -t javacc-image .
```

Usage:

```bash
docker run -it --rm javacc-image -v "$(pwd)":/app javacc /app/Evaluator.jj
```

It works okay, but the grammar file is quite complex and converting our existing grammar would involve substantial work, it's a similar problem as with these stream-parsers where you must produce AST nodes manually. 

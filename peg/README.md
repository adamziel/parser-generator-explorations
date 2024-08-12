This is an attempt to build a dependency-free C parser using peg.

```
peg ./mysql-versionless.peg > mysql-versionless.c
gcc -o parser main.c
./parser test.sql
```

It doesn't process the input correctly yet, and I'm not sure whether it actually
produces an AST.

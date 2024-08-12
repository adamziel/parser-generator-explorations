Attempt with canopy: https://canopy.jcoglan.com/langs/javascript.html

Run this command to generate a parser:

```js
node node_modules/canopy/bin/canopy url.peg --lang js
```

It seems like it can turn a string into a tree structure with easily-defined custom objects for each node type.

Good.

I converted the grammar to the PEG format in mysql-versionless.peg and did this:

```
node node_modules/canopy/bin/canopy mysql-versionless.peg --lang js 
```

The parser has 4MB of code, which is also a lot.

I then parsed a simple query:

```
node mysql-versionless-run.js > mysql-parse-output.out
// parses: SELECT`a`FROM;
```

The output has 28,000 lines. Wow. That's a lot for such as simple query. Furthermore, it seems to have parsed multiple alternative branches instead
of doing a lookahead to choose the right one. 

I won't be continuing with exploring Canopy.

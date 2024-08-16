#!/bin/bash

bun 1-ebnf-to-json.js ./MySQLParser-reordered-for-less-ambiguity.ebnf > MySQLParser.json
python 2-cli.py all ./MySQLParser.json --format=json > ../custom-parser/MySQLParser.json

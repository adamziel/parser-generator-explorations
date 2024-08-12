#!/bin/bash

npx peggy -o peggy_parser.js --format es MySQL.pegjs
python postprocess.py peggy_parser.js

bunx pegjs MySQL.pegjs
mv MySQL.js peg_parser.js

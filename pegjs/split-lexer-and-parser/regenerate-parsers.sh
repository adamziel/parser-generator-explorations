#!/bin/bash

npx peggy -o peggy_parser.js --format es MySQLParser-gemini.pegjs
bunx pegjs MySQLParser-gemini.pegjs; mv MySQLParser-gemini.js peg_parser.js

#!/bin/bash

python lark_json.py test.json
python -m lark.tools.standalone verilog.lark > verilog.py

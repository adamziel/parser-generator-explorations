from typing import List, Dict, Any, Optional, Union

# Grammar definitions
grammar = [
    {
        "name": "start",
        "bnf": [["selectStatement"]]
    },
    {
        "name": "selectStatement",
        "bnf": [["SELECT", "columns", "fromSection?", "joinSection*"]]
    },
    {
        "name": "columns",
        "bnf": [["column_list_item+"]]
    },
    {
        "name": "column_list_item",
        "bnf": [["column", ",",], ["column"]]
    },
    {
        "name": "column",
        "bnf": [["IDENTIFIER"]]
    },
    {
        "name": "fromSection",
        "bnf": [["FROM", "IDENTIFIER"]]
    },
    {
        "name": "joinSection",
        "bnf": [["JOIN", "IDENTIFIER", "ON", "IDENTIFIER", "=", "IDENTIFIER"]]
    }
]

class ParseError(Exception):
    pass

class Parser:
    def __init__(self, grammar: List[Dict[str, Any]], tokens: List[str]):
        self.grammar = self._expand_grammar(grammar)
        self.path = []
        self.tokens = tokens
        self.position = 0

    def _expand_grammar(self, grammar: List[Dict[str, Any]]) -> None:
        expanded_grammar = { rule["name"]: {} for rule in grammar }
        for rule in grammar:
            bnfs = []
            for branch in rule["bnf"]:
                new_branch = []
                for predicate in branch:
                    quantity = ""
                    if predicate.endswith("*"):
                        name = predicate[:-1]
                        quantity = "zero_or_more"
                    elif predicate.endswith("+"):
                        name = predicate[:-1]
                        quantity = "one_or_more"
                    elif predicate.endswith("?"):
                        name = predicate[:-1]
                        quantity = "zero_or_one"
                    else:
                        name = predicate
                    new_branch.append({
                        "name": name,
                        "quantity": quantity,
                        "is_terminal": name not in expanded_grammar
                    })
                bnfs.append(new_branch)
            expanded_grammar[rule["name"]] = bnfs
        return expanded_grammar

    def parse(self, rule_or_terminal: str) -> Union[Dict[str, Any], None]:
        is_terminal = rule_or_terminal not in self.grammar
        if is_terminal:
            return self._match_token(rule_or_terminal)
        
        rule = self.grammar[rule_or_terminal]
        children = []
        
        matched_branch = None
        starting_position = self.position
        for branch in rule:
            self.position = starting_position
            potential_match = []
            for subrule in branch:
                if subrule["quantity"] == "zero_or_more":
                    matched_child = self._parse_zero_or_more(subrule['name'])
                    if not matched_child:
                        continue
                elif subrule["quantity"] == "zero_or_one":
                    matched_child = self._parse_zero_or_one(subrule['name'])
                    if not matched_child:
                        continue
                elif subrule["quantity"] == "one_or_more":
                    matched_child = self._parse_one_or_more(subrule['name'])
                else:
                    matched_child = self.parse(subrule['name'])
                if matched_child is None:
                    break
                if subrule['is_terminal']:
                    potential_match.append(matched_child)
                else:
                    potential_match.append({subrule['name']: matched_child})
            else:
                children.extend(potential_match)
                matched_branch = branch
                break
        
        if matched_branch is None:
            self.position = starting_position
            return None
        
        return children
    
    def _match_token(self, token_id: str) -> bool:
        if self.position < len(self.tokens) and (self.tokens[self.position] == token_id):
            self.position += 1
            return token_id
        return None

    def _parse_zero_or_more(self, rule_name: str) -> List[Dict[str, Any]]:
        result = []
        while True:
            node = self.parse(rule_name)
            if node is None:
                break
            result.append(node)
        return result

    def _parse_one_or_more(self, rule_name: str) -> List[Dict[str, Any]]:
        result = []
        first_node = self.parse(rule_name)
        if first_node is None:
            return None
        result.append(first_node)
        
        while True:
            node = self.parse(rule_name)
            if node is None:
                break
            result.append(node)
        return result

    def _parse_zero_or_one(self, rule_name: str) -> Optional[Dict[str, Any]]:
        return self.parse(rule_name)

# Sample tokens from a SQL statement: "SELECT col1, col2 FROM table1 JOIN table2 ON table1.id = table2.id"
tokens = ["SELECT", "IDENTIFIER", ",", "IDENTIFIER", "FROM", "IDENTIFIER", "JOIN", "IDENTIFIER", "ON", "IDENTIFIER", "=", "IDENTIFIER", "JOIN", "IDENTIFIER", "ON", "IDENTIFIER", "=", "IDENTIFIER"]

# Create a parser instance and parse the tokens
parser = Parser(grammar, tokens)
parse_tree = parser.parse("start")

# Output the parse tree
from pprint import pprint
pprint(parse_tree)


class PHPParserGenerator:
    def __init__(self, grammar: List[Dict[str, Any]]):
        self.grammar = grammar
        self.php_code = ""

    def generate(self) -> str:
        self._start_class()
        for rule in self.grammar:
            self._generate_method_for_rule(rule)
        self._end_class()
        return self.php_code

    def _start_class(self) -> None:
        self.php_code += """<?php

class SQLParser {
    private $tokens;
    private $position;

    public function __construct($tokens) {
        $this->tokens = $tokens;
        $this->position = 0;
    }

    public function parse() {
        return $this->parseSelectStatement();
    }

    private function matchToken($expectedToken) {
        if ($this->position < count($this->tokens) && ($this->tokens[$this->position] == $expectedToken || $expectedToken == 'IDENTIFIER')) {
            $this->position++;
            return true;
        }
        return false;
    }

"""

    def _end_class(self) -> None:
        self.php_code += """}
?>
"""

    def _generate_method_for_rule(self, rule: Dict[str, Any]) -> None:
        method_name = f"parse{rule['name'].capitalize()}"
        self.php_code += f"""    private function {method_name}() {{
        $startPosition = $this->position;
        $node = ['rule' => '{rule['name']}', 'children' => []];
"""

        for part in rule['bnf']:
            if part.endswith("*"):
                rule_name = part[:-1]
                self.php_code += f"""
        while (true) {{
            $childNode = $this->{method_name}();
            if ($childNode === null) {{
                break;
            }}
            $node['children'][] = $childNode;
        }}
"""
            elif part.endswith("+"):
                rule_name = part[:-1]
                self.php_code += f"""
        $firstNode = $this->{method_name}();
        if ($firstNode === null) {{
            $this->position = $startPosition;
            return null;
        }}
        $node['children'][] = $firstNode;
        
        while (true) {{
            $childNode = $this->{method_name}();
            if ($childNode === null) {{
                break;
            }}
            $node['children'][] = $childNode;
        }}
"""
            elif part.endswith("?"):
                rule_name = part[:-1]
                self.php_code += f"""
        $childNode = $this->{method_name}();
        if ($childNode !== null) {{
            $node['children'][] = $childNode;
        }}
"""
            else:
                if part.isupper():  # It's a terminal token
                    self.php_code += f"""
        if (!$this->matchToken('{part}')) {{
            $this->position = $startPosition;
            return null;
        }}
        $node['children'][] = ['rule' => '{part}', 'token' => $this->tokens[$this->position - 1]];
"""
                else:  # It's a non-terminal rule
                    self.php_code += f"""
        $childNode = $this->{method_name}();
        if ($childNode === null) {{
            $this->position = $startPosition;
            return null;
        }}
        $node['children'][] = $childNode;
"""
        self.php_code += f"""
        return $node;
    }}
"""

# # Example usage
# generator = PHPParserGenerator(grammar)
# php_parser_code = generator.generate()

# print(php_parser_code)

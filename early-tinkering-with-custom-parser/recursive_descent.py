from typing import List, Dict, Any, Optional, Union

# Grammar definitions
grammar = [
    {
        "name": "selectStatement",
        "bnf": [["SELECT", "columns", "fromSection?", "joinSection*"]]
    },
    {
        "name": "columns",
        "bnf": [["column", ",", "columns"], ["column"]]
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
        self.grammar = {rule["name"]: rule["bnf"] for rule in grammar}
        self.tokens = tokens
        self.position = 0

    def parse(self, rule_or_terminal: str) -> Union[Dict[str, Any], None]:
        is_terminal = rule_or_terminal not in self.grammar
        if is_terminal:
            return self._match_token(rule_or_terminal)
        
        rule = self.grammar[rule_or_terminal]
        node = {"rule": rule_or_terminal, "children": []}
        
        matched_branch = None
        starting_position = self.position
        for branch in rule:
            self.position = starting_position
            potential_match = []
            for part in branch:
                if part.endswith("*"):
                    matched_child = self._parse_zero_or_more(part[:-1])
                    if not matched_child:
                        continue
                elif part.endswith("?"):
                    matched_child = self._parse_zero_or_one(part[:-1])
                    if not matched_child:
                        continue
                elif part.endswith("+"):
                    matched_child = self._parse_one_or_more(part[:-1])
                else:
                    matched_child = self.parse(part)
                if not matched_child:
                    print(f"Failed to match {part}")
                    break
                potential_match.append({"rule": part, "token": self.tokens[self.position - 1]})
            else:
                print(f"Matched branch: {branch}")
                node["children"].extend(potential_match)
                matched_branch = branch
                break
        
        if matched_branch is None:
            self.position = starting_position
            return None
        
        return node
    
    def _match_token(self, token_id: str) -> bool:
        if self.position < len(self.tokens) and (self.tokens[self.position] == token_id):
            self.position += 1
            return True
        return False

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
            return False
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
parse_tree = parser.parse("selectStatement")

# Output the parse tree
from pprint import pprint
pprint(parse_tree)


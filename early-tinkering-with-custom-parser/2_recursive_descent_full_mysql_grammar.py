"""
@TODO:

* Tokenize MySQL Queries
* Inline fragments
* Generate a PHP parser
* Generate a parse table to find the next rule based on a token lookup, not a grammar scan
  (this requires expanding things quite a bit in the memory, it may or may not be worth it
   depending on this parser's speed)
"""
from typing import List, Dict, Any, Optional, Union
from collections import defaultdict

class ParseError(Exception):
    pass

class Parser:
    def __init__(self, grammar: List[Dict[str, Any]], tokens: List[str]):
        self.grammar = self._expand_grammar(grammar)
        self.path = []
        self.tokens = tokens
        self.position = 0
        self.trace = []

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
                        "is_terminal": name not in expanded_grammar,
                        "is_fragment": name.startswith("%")
                    })
                bnfs.append(new_branch)
            expanded_grammar[rule["name"]] = bnfs
        return expanded_grammar

    def parse_start(self) -> Dict[str, Any]:
        result = self.parse("query")
        return result

    def parse(self, rule_or_terminal: str) -> Union[Dict[str, Any], None]:
        is_terminal = rule_or_terminal not in self.grammar
        if is_terminal:
            return self._match_token(rule_or_terminal)
        
        # Avoid infinite recursion for rules that refer to themselves
        if rule_or_terminal in self.trace:
            return None
        
        rule = self.grammar[rule_or_terminal]
        
        matched_branch = None
        starting_position = self.position
        self.trace.append(rule_or_terminal)
        for branch in rule:
            self.position = starting_position
            match = defaultdict(list)
            for subrule in branch:
                if subrule["quantity"] == "zero_or_more":
                    matched_children = self._parse_zero_or_more(subrule['name'])
                    if not matched_children:
                        continue
                elif subrule["quantity"] == "zero_or_one":
                    matched_children = self._parse_zero_or_one(subrule['name'])
                    if not matched_children:
                        continue
                elif subrule["quantity"] == "one_or_more":
                    matched_children = self._parse_one_or_more(subrule['name'])
                else:
                    matched_children = self.parse(subrule['name'])

                if matched_children is None:
                    # print(f"Failed to match {subrule['name']}", self.trace)
                    break

                match[subrule['name']].append(matched_children)
                # self.update_match(match, subrule['name'], matched_children)
            else:
                matched_branch = branch
                break
        self.trace.pop()

        if matched_branch is None:
            self.position = starting_position
            return None
        
        return match
    
    def update_match(self, match, subrule_name, matched_children):
        while isinstance(matched_children, list) and len(matched_children) == 1:
            matched_children = matched_children[0]
        if not subrule_name.startswith("%"):
            match[subrule_name].append(matched_children)
            return
        if isinstance(matched_children, dict):
            for key, value in matched_children.items():
                if isinstance(value, dict):
                    self._safe_extend_dict(match, value)
                else:
                    match[key].append(value)
        elif isinstance(matched_children, list):
            if len(matched_children) == 1:
                self.update_match(match, subrule_name, matched_children[0])
            else:
                for item in matched_children:
                    self.update_match(match, subrule_name, item)
        else:
            match[subrule_name].append(matched_children)

    def _safe_extend_dict(self, base_dict, dict2):
        for key, value in dict2.items():
            if key in base_dict:
                if not isinstance(base_dict[key], list):
                    base_dict[key] = [base_dict[key]]
                base_dict[key].append(value)
            else:
                base_dict[key] = value
        return base_dict
    
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


with open("MySQLParser.json") as fp:
    import json
    grammar = json.load(fp)

tokens = [
    "SELECT_SYMBOL", "IDENTIFIER", "COMMA_SYMBOL", "IDENTIFIER", 
    "FROM_SYMBOL", "IDENTIFIER",
    "EOF"
]

# Create a parser instance and parse the tokens
parser = Parser(grammar, tokens)
parse_tree = parser.parse_start()

# Output the parse tree
print(json.dumps(parse_tree, indent=2))
# from pprint import pprint
# pprint(parse_tree, indent=2, width=1)

from collections import defaultdict
from typing import Dict, List, Tuple

def find_prefixes_to_factor(rules: List[List[str]]) -> List[str]:
    prefixes = defaultdict(lambda: 0)
    for rule in rules:
        if len(rule):
            prefixes[rule[0]] += 1
    return [prefix for prefix, count in prefixes.items() if count > 1]

def factor_nonterminal(grammar, name):
    prefixes = find_prefixes_to_factor(grammar[name])
    if len(prefixes) == 0:
        return False, grammar

    did_change = False
    new_grammar = defaultdict(list, grammar)
    new_rules = defaultdict(list)
    for i, rule in enumerate(grammar[name]):
        if rule[0] in prefixes:
            new_rule_name = f"{name}_{rule[0]}"
            if len(rule) > 1:
                new_grammar[new_rule_name].append(rule[1:])
            new_rules[rule[0]] = [rule[0], new_rule_name]
            did_change = True
        else:
            new_rules[i] = rule
    new_grammar[name] = list(new_rules.values())
    return did_change, dict(new_grammar)

def left_factor(grammar):
    while True:
        did_change = False
        for key in grammar.keys():
            did_change_key, grammar = factor_nonterminal(grammar, key)
            did_change = did_change or did_change_key
        if not did_change:
            break
    return grammar
    

# Example usage
input_grammar = {
    "simpleStatement": [
        ["ALTER", "TABLE", "END"],
        ["ALTER", "DATABASE", "END"],
        ["ALTER", "TABLE", "BEGIN"],
        ["ALTER", "DATABASE", "BEGIN"],
        ["ALTER", "RIKE"],
        ["ALTER", "USER"],
        ["DOIT"],
        ["ORDONT"],
        ["SELECT", "FROM", "WHERE"],
        ["SELECT", "FROM"]
    ],
    "alterStatement": [
        ["ALTER", "TABLE"],
        ["ALTER", "DATABASE"]
    ],
    "alterRoleStatement": [
        ["ALTER", "RIKE"],
        ["ALTER", "USER"],
        ["DOIT"],
        ["ORDONT"]
    ],
    "anotherRule": [
        ["DOIT"],
        ["ORDONT"]
    ],
    "selectStatement": [
        ["SELECT", "FROM", "WHERE"],
        ["SELECT", "FROM"]
    ]
}

# Left-factor the grammar
left_factored_grammar = left_factor(input_grammar)

# Output the result
print(print_grammar(left_factored_grammar))

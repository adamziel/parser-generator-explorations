from typing import Dict, List, Set
from collections import defaultdict

Grammar = Dict[str, List[List[str]]]

def compute_first(grammar: Grammar) -> Dict[str, Set[str]]:
    first: Dict[str, Set[str]] = defaultdict(set)
    
    for productions in grammar.values():
        for production in productions:
            for symbol in production:
                first[symbol] = {symbol}

    while True:
        updated = False
        for non_terminal, productions in grammar.items():
            for production in productions:
                for symbol in production:
                    before = len(first[non_terminal])
                    first[non_terminal] |= first[symbol]
                    if len(first[non_terminal]) > before:
                        updated = True
                    if symbol not in grammar:  # If it's a terminal
                        break
        if not updated:
            break
    return first

def compute_follow(grammar: Grammar, first: Dict[str, Set[str]]) -> Dict[str, Set[str]]:
    follow: Dict[str, Set[str]] = {nt: set() for nt in grammar.keys()}
    start_symbol = next(iter(grammar.keys()))
    follow[start_symbol].add('$')

    while True:
        updated = False
        for non_terminal, productions in grammar.items():
            for production in productions:
                for i, symbol in enumerate(production):
                    if symbol in grammar:  # If it's a non-terminal
                        if i == len(production) - 1:
                            before = len(follow[symbol])
                            follow[symbol] |= follow[non_terminal]
                            if len(follow[symbol]) > before:
                                updated = True
                        else:
                            rest = production[i+1:]
                            first_of_rest = set()
                            for s in rest:
                                first_of_rest |= first[s]
                                if s not in grammar:  # If it's a terminal
                                    break
                            before = len(follow[symbol])
                            follow[symbol] |= first_of_rest
                            if len(follow[symbol]) > before:
                                updated = True
                            if all(s in grammar for s in rest):  # If all remaining symbols are non-terminals
                                follow[symbol] |= follow[non_terminal]
                                if len(follow[symbol]) > before:
                                    updated = True
        if not updated:
            break
    return follow

def has_unresolvable_conflicts(grammar: Grammar, first: Dict[str, Set[str]], follow: Dict[str, Set[str]]) -> bool:
    for non_terminal, productions in grammar.items():
        first_sets = [set(first[prod[0]]) for prod in productions]
        
        # Check for unresolvable FIRST/FIRST conflicts
        for i in range(len(productions)):
            for j in range(i + 1, len(productions)):
                if first_sets[i] & first_sets[j]:
                    if productions[i][0] == productions[j][0] and len(productions[i]) != len(productions[j]):
                        print(f"Unresolvable FIRST/FIRST conflict in {non_terminal} between {productions[i]} and {productions[j]}")
                        return True

        # Check for unresolvable FIRST/FOLLOW conflicts
        for i, prod in enumerate(productions):
            if prod[0] in grammar:  # If it's a non-terminal
                if follow[non_terminal] & first[prod[0]]:
                    # Check if this conflict is resolvable through left-factoring
                    if not any(p[0] == prod[0] for p in productions if p != prod):
                        print(f"Unresolvable FIRST/FOLLOW conflict in {non_terminal} for production {prod}")
                        return True

    return False

def can_be_ll1(grammar: Grammar) -> bool:
    first = compute_first(grammar)
    follow = compute_follow(grammar, first)
    
    if has_unresolvable_conflicts(grammar, first, follow):
        return False

    print("\nFIRST sets:")
    for symbol, first_set in first.items():
        print(f"FIRST({symbol}) = {first_set}")
    
    print("\nFOLLOW sets:")
    for non_terminal, follow_set in follow.items():
        print(f"FOLLOW({non_terminal}) = {follow_set}")

    print("\nNo unresolvable conflicts found. The grammar might be transformable to LL(1).")
    return True

# Your grammar
grammar: Grammar = {
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

result = can_be_ll1(grammar)
# print(f"\nCan the grammar be transformed to LL(1)? {'Yes' if result else 'No'}")

import json
from ebnfutils import hash_grammar, encode_as_ebnf, normalize_epsilons
with open("MySQLParser-expanded-right-recursive.json") as fp:
    grammar = hash_grammar(json.load(fp))

result = can_be_ll1(grammar)
print(f"\nCan the grammar potentially be transformed to LL(1)? {'Yes' if result else 'No'}")
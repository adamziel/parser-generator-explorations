from typing import Dict, List, Tuple


def is_terminal(symbol, productions):
    return symbol not in productions

def left_expand(productions):
    """
    Left-expand a grammar like:

    productions = {
        'simpleStatement': [['alterStatement', 'END'], ['alterStatement', 'BEGIN'], ['alterRoleStatement'], ['selectStatement']],
        'alterStatement': [['ALTER', 'TABLE'], ['ALTER', 'DATABASE']],
        'alterRoleStatement': [['ALTER', 'RIKE'], ['ALTER', 'USER']],
        'selectStatement': [['SELECT', 'FROM', 'WHERE'], ['SELECT', 'FROM']],
    }

    Transforms every initial non-terminal symbol on a RHS so that the RHS of every rule begins with a terminal.

    The goal is to prepare the grammar for left factoring.
    """
    expanded_productions = {}

    def expand_rule(rule, depth=0):
        # if depth > 200:
        #     print(f"Recursion depth exceeded for", rule)
        #     print(encode_as_ebnf(productions))
        #     exit(0)
        if is_terminal(rule[0], productions):
            return [rule]
        else:
            new_rules = []
            first_symbol = rule[0]
            remaining_symbols = rule[1:]
            for production in productions[first_symbol]:
                new_rule = production + remaining_symbols
                new_rules.extend(expand_rule(new_rule, depth + 1))
            return new_rules

    for non_terminal, rules in productions.items():
        expanded_rules = []
        for rule in rules:
            expanded_rules.extend(expand_rule(rule))
        expanded_productions[non_terminal] = expanded_rules
    return expanded_productions

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

def left_factor(grammar, max_iterations=100):
    print(f"Left factoring!")
    iterations = 0
    while True:
        print(f"Iteration {iterations}, grammar size: {len(grammar)}")
        if iterations >= max_iterations:
            break
        iterations += 1
        did_change = False
        for key in grammar.keys():
            did_change_key, grammar = factor_nonterminal(grammar, key)
            did_change = did_change or did_change_key
        if not did_change:
            return False, grammar
    return True, grammar
    


def remove_empty_branches(productions):
    """
    Removes all empty branches from the grammar.
    """
    new_productions = {}
    for non_terminal, rules in productions.items():
        new_rules = []
        for rule in rules:
            if len(rule) > 0:
                new_rules.append(rule)
        new_productions[non_terminal] = new_rules
    return new_productions

def deduplicate_branches(productions):
    """
    For each non-terminal, it finds the branches that are the same and
    merges them into a single branch.
    """
    new_productions = {}
    for non_terminal, rules in productions.items():
        seen = set()
        new_rules = []
        for rule in rules:
            key = tuple(rule)
            if key not in seen:
                new_rules.append(rule)
                seen.add(key)
        new_productions[non_terminal] = new_rules
    return new_productions

def deduplicate_nonterminals(productions):
    """
    Merges all non-terminals that have the same right-hand side and
    refactors all references to them.
    """
    substitutions = {}
    new_productions = {}
    for non_terminal, rules in productions.items():
        key = tuple([tuple(rule) for rule in rules])
        if key in substitutions:
            substitutions[non_terminal] = substitutions[key]
        else:
            substitutions[key] = non_terminal
            new_productions[non_terminal] = rules
    for non_terminal, rules in new_productions.items():
        new_productions[non_terminal] = [
            [substitutions.get(symbol, symbol) for symbol in rule]
            for rule in rules
        ]
    return new_productions


def remove_empty_nonterminals(productions):
    """
    Removes all non-terminals where all branches are empty
    and all references to them.
    """
    empty_non_terminals = set()
    for non_terminal, rules in productions.items():
        if all([len(rule) == 0 for rule in rules]):
            empty_non_terminals.add(non_terminal)
    new_productions = {}
    for non_terminal, rules in productions.items():
        if non_terminal in empty_non_terminals:
            continue
        new_rules = []
        for rule in rules:
            new_rules.append([symbol for symbol in rule if symbol not in empty_non_terminals])
        if new_rules:
            new_productions[non_terminal] = new_rules
    return new_productions

def reduce_grammar(productions):
    productions = deduplicate_branches(productions)
    productions = deduplicate_nonterminals(productions)
    productions = remove_empty_branches(productions)
    productions = remove_empty_nonterminals(productions)
    productions = normalize_epsilons(productions)
    return productions

# Example grammar
productions = {
    'simpleStatement': [['alterStatement', 'END'], ['alterStatement', 'BEGIN'], ['alterRoleStatement'], ['selectStatement']],
    'alterStatement': [['ALTER', 'TABLE'], ['ALTER', 'DATABASE']],
    'alterRoleStatement': [['ALTER', 'RIKE'], ['ALTER', 'USER'], ['anotherRule']],
    'anotherRule': [['DOIT'], ['ORDONT']],
    'selectStatement': [['SELECT', 'FROM', 'WHERE'], ['SELECT', 'FROM']],
}

import json
from ebnfutils import hash_grammar, encode_as_ebnf, normalize_epsilons
with open("MySQLParser-expanded-right-recursive.json") as fp:
    productions = hash_grammar(json.load(fp))

for i in range(2):
    productions = left_expand(productions)
    print("Expansion finished")
    while True:
        changed, productions = left_factor(productions, max_iterations=1)
        productions = reduce_grammar(productions)
        productions = reduce_grammar(productions)
        productions = reduce_grammar(productions)
        productions = reduce_grammar(productions)
        print(f"Grammar size after another factoring round: {len(productions)}")
        if not changed:
            break

print("Grammar LL normalization finished")

# Print the factored grammar
print(encode_as_ebnf(productions))

from collections import defaultdict
class ParseTableBuilder:
    def __init__(self, productions):
        self.productions = productions  # Dictionary where key is the non-terminal and value is the list of productions.
        self.non_terminals = list(productions.keys())
        self.terminals = set()  # To be computed from the grammar.
        self.first_sets = defaultdict(set)
        self.follow_sets = defaultdict(set)
        self.parse_table = defaultdict(dict)
        self.compute_terminals()
        self.compute_first_sets()
        self.compute_follow_sets()
        self.build_parsing_table()

    def compute_terminals(self):
        for rules in self.productions.values():
            for rule in rules:
                for symbol in rule:
                    if symbol not in self.non_terminals:
                        self.terminals.add(symbol)
        self.terminals.add('$')  # End of input symbol

    def compute_first_sets(self):
        for non_terminal in self.non_terminals:
            self.first_sets[non_terminal] = self.compute_first(non_terminal)

    def compute_first(self, non_terminal, depth=0):
        first = set()
        if depth > 200:
            print(f"Recursion depth exceeded for {non_terminal}")
        for rule in self.productions[non_terminal]:
            if rule[0] in self.terminals:
                first.add(rule[0])
            else:
                for symbol in rule:
                    if symbol in self.terminals:
                        first.add(symbol)
                        break
                    else:
                        symbol_first = self.compute_first(symbol, depth + 1)
                        first.update(symbol_first - {'ε'})
                        if 'ε' not in symbol_first:
                            break
                else:
                    first.add('ε')
        return first

    def compute_follow_sets(self):
        self.follow_sets[self.non_terminals[0]].add('$')  # Start symbol follow set includes end of input
        changed = True
        while changed:
            changed = False
            for non_terminal in self.non_terminals:
                for rule in self.productions[non_terminal]:
                    follow_temp = self.follow_sets[non_terminal].copy()
                    for symbol in reversed(rule):
                        if symbol.isupper():  # Non-terminal
                            follow_size_before = len(self.follow_sets[symbol])
                            self.follow_sets[symbol].update(follow_temp)
                            if 'ε' in self.first_sets[symbol]:
                                follow_temp.update(self.first_sets[symbol] - {'ε'})
                            else:
                                follow_temp = self.first_sets[symbol].copy()
                            if len(self.follow_sets[symbol]) > follow_size_before:
                                changed = True
                        else:
                            follow_temp = {symbol}

    def build_parsing_table(self):
        for non_terminal in self.non_terminals:
            for rule in self.productions[non_terminal]:
                first = self.compute_first_for_rule(rule)
                for terminal in first:
                    if terminal != 'ε':
                        if terminal in self.parse_table[non_terminal]:
                            print(f"Conflict detected for {non_terminal} with terminal {terminal}.")
                        self.parse_table[non_terminal][terminal] = rule
                if 'ε' in first:
                    for terminal in self.follow_sets[non_terminal]:
                        if terminal in self.parse_table[non_terminal]:
                            print(f"Conflict detected for {non_terminal} with terminal {terminal}.")
                        self.parse_table[non_terminal][terminal] = rule

    def compute_first_for_rule(self, rule):
        first = set()
        for symbol in rule:
            if symbol in self.terminals:
                first.add(symbol)
                break
            else:
                symbol_first = self.first_sets[symbol]
                first.update(symbol_first - {'ε'})
                if 'ε' not in symbol_first:
                    break
        else:
            first.add('ε')
        return first

    def display_parsing_table(self):
        print("Parsing Table:")
        print(f"{'Non-Terminal':<15} {'Terminal':<30} {'Production'}")
        for non_terminal in self.parse_table:
            for terminal in self.parse_table[non_terminal]:
                print(f"{non_terminal:<15} {terminal:<10} {' -> '.join(self.parse_table[non_terminal][terminal])}")


pt = ParseTableBuilder(productions)
pt.display_parsing_table()

# Print the factored grammar
# print(encode_as_ebnf(productions))

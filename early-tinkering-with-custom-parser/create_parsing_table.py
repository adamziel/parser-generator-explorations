from collections import defaultdict

token_ids = {
    'SELECT': 1,
    'FROM': 2,
    'WHERE': 3,
    'backticks_identifier': 4,
    'single_quote_identifier': 5,
    ',': 6,
    'TABLE': 7,
    'is_bit': 8,
    'is_not_bit': 9,
    'operator': 10,
    '$': 0,  # End of input marker
}

pseudo_sql_grammar = [
    {'name': 'selectStatement', 'branches': [[{"token":'SELECT'}, {"rule":'columnList'}, {"token":'FROM', "type": "optional"}, {"rule":'tableList', "type": "optional"}, {"rule":'whereClause', "type": "optional"}, {"rule": "$"}]]},
    {'name': 'columnList', 'branches': [[{"rule":'column'}, {"rule":'moreColumns', "type": "zero_or_more"}]]},
    {'name': 'moreColumns', 'branches': [[{"token":','}, {"rule":'column'}]]},
    {'name': 'column', 'branches': [[{"token":'backticks_identifier'}], [{"token":'single_quote_identifier'}]]},
    {'name': 'tableList', 'branches': [[{"rule":'table'}, {"rule":'moreTables', "type": "zero_or_more"}]]},
    {'name': 'moreTables', 'branches': [[{"token":','}, {"rule":'table'}]]},
    {'name': 'table', 'branches': [[{"token":'backticks_identifier'}], [{"token":'single_quote_identifier'}]]},
    {'name': 'whereClause', 'branches': [[{"token": "WHERE"}, {"rule":'condition'}]]}, 
    {'name': 'condition', 'branches': [[{"rule":'expr'}, {"rule":'bit_expr'}, {"rule":'not_bit_expr'}]]}, 
    {'name': 'expr', 'branches': [[{"token":'backticks_identifier'}, {"token":'operator'}, {"token":'backticks_identifier'}]]}, 
    {'name': 'bit_expr', 'branches': [[{"token":'backticks_identifier'}, {"token":'operator'}, {"token":'backticks_identifier'}, {"token":'is_bit'}]]}, 
    {'name': 'not_bit_expr', 'branches': [[{"token":'backticks_identifier'}, {"token":'operator'}, {"token":'backticks_identifier'}, {"token":'is_not_bit'}]]}, 
]

pseudo_sql_grammar = [
    {'name': 'selectStatement', 'branches': [[{"token":'SELECT'}]]},
]

class HashableDict(dict):
    def __hash__(self):
        return hash(frozenset(self.items()))

    def __eq__(self, other):
        if isinstance(other, HashableDict):
            return frozenset(self.items()) == frozenset(other.items())
        return NotImplemented
    
    def __str__(self) -> str:
        return 'HashableDict(' + super().__str__() + ')'

class HashableList(list):
    def __hash__(self):
        return hash(tuple(self))

    def __eq__(self, other):
        if isinstance(other, HashableList):
            return tuple(self) == tuple(other)
        return NotImplemented

    def __str__(self) -> str:
        return 'HashableList(' + super().__str__() + ')'

def make_hashable(d):
    if isinstance(d, dict):
        return HashableDict({k: make_hashable(v) for k, v in d.items()})
    elif isinstance(d, list):
        return HashableList([make_hashable(v) for v in d])
    return d


# Assuming augmented grammar with a start rule 'S'
augmented_grammar = [{'name': 'S', 'branches': [[{'rule': 'selectStatement'}]]}] + pseudo_sql_grammar


def first(symbol, grammar, lookahead_depth=1):
    # Calculate the FIRST set for a given symbol
    first_set = set()
    if symbol in token_ids:  # Terminal symbol
        first_set.add(symbol)
    else:  # Non-terminal symbol
        for rule in grammar:
            if rule['name'] == symbol:
                for branch in rule['branches']:
                    for i in range(lookahead_depth):
                        if i < len(branch):
                            item = branch[i]
                            if 'token' in item:
                                first_set.add(item['token'])
                                break
                            else:
                                sub_first = first(item['rule'], grammar, lookahead_depth)
                                first_set.update(sub_first - set(['']))
                                if '' not in sub_first:
                                    break
                        else:
                            first_set.add('')
                            break
    return first_set


def follow(symbol, grammar, start_symbol='S', lookahead_depth=1):
    # Calculate the FOLLOW set for a given symbol
    follow_set = set()
    if symbol == start_symbol:
        follow_set.add('$')  # Add end-of-input marker to FOLLOW(S)
    for rule in grammar:
        for branch in rule['branches']:
            for i, item in enumerate(branch):
                if 'rule' in item and item['rule'] == symbol:
                    if i < len(branch) - 1:
                        next_item = branch[i + 1]
                        if 'token' in next_item:
                            follow_set.add(next_item['token'])
                        else:
                            follow_set.update(first(next_item['rule'], grammar, lookahead_depth) - set(['']))
                            if '' in first(next_item['rule'], grammar, lookahead_depth):
                                follow_set.update(follow(rule['name'], grammar, start_symbol, lookahead_depth))
                    else:
                        follow_set.update(follow(rule['name'], grammar, start_symbol, lookahead_depth))
    return follow_set


def closure(items, grammar, lookahead_depth=1):
    # Calculate the closure of a set of LR(n) items
    closure_set = set(items)
    while True:
        new_items = set()
        for item in closure_set:
            dot_index = item[1]
            if dot_index < len(item[0]['branch']):
                next_symbol = item[0]['branch'][dot_index]
                if 'rule' in next_symbol:
                    lookahead = []
                    for j in range(dot_index + 1, min(dot_index + 1 + lookahead_depth, len(item[0]['branch']))):
                        lookahead_symbol = item[0]['branch'][j]
                        if 'token' in lookahead_symbol:
                            lookahead.append(lookahead_symbol['token'])
                        else:
                            lookahead.extend(list(first(lookahead_symbol['rule'], grammar, lookahead_depth) - set([''])))
                            if '' not in first(lookahead_symbol['rule'], grammar, lookahead_depth):
                                break
                    else:
                        if len(lookahead) < lookahead_depth:
                            lookahead.extend(item[2])  # Add lookahead from the current item
                            lookahead = lookahead[:lookahead_depth]  # Keep only the first 'lookahead_depth' symbols

                    for rule in grammar:
                        if rule['name'] == next_symbol['rule']:
                            for branch in rule['branches']:
                                new_item = (make_hashable({'rule': rule['name'], 'branch': branch}), 0, tuple(lookahead))
                                if new_item not in closure_set:
                                    new_items.add(new_item)
        if not new_items:
            break
        closure_set.update(new_items)
    return closure_set


def goto(items, symbol, grammar, lookahead_depth=1):
    # Calculate the GOTO function for a set of LR(n) items and a symbol
    goto_set = set()
    for item in items:
        dot_index = item[1]
        if dot_index < len(item[0]['branch']):
            next_symbol = item[0]['branch'][dot_index]
            if 'token' in next_symbol and next_symbol['token'] == symbol or 'rule' in next_symbol and next_symbol['rule'] == symbol:
                goto_set.add((item[0], dot_index + 1, item[2]))
    return closure(goto_set, grammar, lookahead_depth)


def build_parsing_table(grammar, lookahead_depth=1):
    # Construct the LR(n) parsing table
    start_rule = grammar[0]
    start_item = (make_hashable({'rule': start_rule['name'], 'branch': start_rule['branches'][0]}), 0, ('$',) * lookahead_depth)  # Assuming augmented grammar
    
    # Calculate canonical collection of LR(n) items
    canonical_collection = []
    initial_state = closure({start_item}, grammar, lookahead_depth)
    canonical_collection.append(initial_state)
    
    state_index = 0
    while state_index < len(canonical_collection):
        current_state = canonical_collection[state_index]
        symbols = set()
        for item in current_state:
            dot_index = item[1]
            if dot_index < len(item[0]['branch']):
                next_symbol = item[0]['branch'][dot_index]
                if 'token' in next_symbol:
                    symbols.add(next_symbol['token'])
                else:
                    symbols.add(next_symbol['rule'])
        for symbol in symbols:
            next_state = goto(current_state, symbol, grammar, lookahead_depth)
            if next_state and next_state not in canonical_collection:
                canonical_collection.append(next_state)
            if next_state:
                # Construct the parsing table entries
                if 'token' in symbol:  # Shift action
                    if (state_index, symbol) not in parsing_table['action']:
                        parsing_table['action'][state_index, symbol] = f'Shift {canonical_collection.index(next_state)}'
                    else:
                        # Conflict: Shift-Reduce or Shift-Shift conflict
                        print(f"Conflict in state {state_index} on symbol {symbol}: Shift-Reduce or Shift-Shift conflict")
                else:  # Goto action
                    parsing_table['goto'][state_index, symbol] = canonical_collection.index(next_state)
        state_index += 1

    # Add Reduce actions
    for state_index, state in enumerate(canonical_collection):
        for item in state:
            if item[1] == len(item[0]['branch']):  # Item is a complete rule
                for lookahead in item[2]:
                    if (state_index, lookahead) not in parsing_table['action']:
                        production_index = next((i for i, rule in enumerate(grammar) if rule['name'] == item[0]['rule'] and rule['branches'].count(item[0]['branch']) > 0), None)
                        parsing_table['action'][state_index, lookahead] = f'Reduce {production_index}'
                    else:
                        # Conflict: Shift-Reduce or Reduce-Reduce conflict
                        print(f"Conflict in state {state_index} on lookahead {lookahead}: Shift-Reduce or Reduce-Reduce conflict")

    return canonical_collection, parsing_table


# Initialize parsing table
parsing_table = {'action': {}, 'goto': {}}

# Build the parsing table
canonical_collection, parsing_table = build_parsing_table(augmented_grammar, lookahead_depth=1)  # Using lookahead depth of 3

# Print the parsing table
print("Parsing Table:")
print("Action:")
for (state, symbol), action in parsing_table['action'].items():
    print(f"State {state}, Symbol {symbol}: {action}")
print("Goto:")
for (state, symbol), next_state in parsing_table['goto'].items():
    print(f"State {state}, Symbol {symbol}: {next_state}")

# Parsing function
def parse(token_stream, parsing_table, grammar):
    token_stream.append('$')  # Add end-of-input marker
    stack = [0]  # Initial state
    input_pointer = 0
    while True:
        current_state = stack[-1]
        current_token = token_stream[input_pointer]
        action = parsing_table['action'].get((current_state, current_token))
        if action is None:
            print("Failure 1")
            return False  # Parsing error

        if action.startswith('Shift'):
            next_state = int(action.split(' ')[1])
            stack.append(token_ids[current_token])
            stack.append(next_state)
            input_pointer += 1
        elif action.startswith('Reduce'):
            production_index = int(action.split(' ')[1])
            production = grammar[production_index]
            length_to_pop = len(production['branches'][0]) * 2  # Pop twice the number of symbols in the production
            stack = stack[:-length_to_pop]
            current_state = stack[-1]
            goto_state = parsing_table['goto'].get((current_state, production['name']))
            if goto_state is None:
                print("Failure 2")
                return False  # Parsing error
            stack.append(production['name'])
            stack.append(goto_state)
        elif action == 'Accept':
            return True  # Parsing successful


# Parse the token streams
token_streams_to_parse = [
    ['SELECT', 'backticks_identifier', '$'],
    # ['SELECT', 'backticks_identifier', ',', 'single_quote_identifier', 'FROM', 'TABLE', 'WHERE', 'backticks_identifier', 'operator', 'backticks_identifier'],
    # ['SELECT', 'backticks_identifier', ',', 'single_quote_identifier', 'FROM', 'TABLE', 'WHERE', 'backticks_identifier', 'operator', 'backticks_identifier', 'is_bit'],
    # ['SELECT', 'backticks_identifier', ',', 'single_quote_identifier', 'FROM', 'TABLE', 'WHERE', 'backticks_identifier', 'operator', 'backticks_identifier', 'is_not_bit'],
]
for token_stream in token_streams_to_parse:
    print(f"Parsing token stream: {token_stream}")
    result = parse(token_stream, parsing_table, augmented_grammar)
    print(f"Result: {'Success' if result else 'Failure'}")
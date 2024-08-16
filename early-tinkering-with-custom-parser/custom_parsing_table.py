import json

json_file = 'MySQLFull.json'
with open(json_file) as file:
    data = json.load(file)


def build_parsing_table(rules):
    index = {}
    for rule in rules:
        index[rule['name']] = rule

    parsing_states = {}
    for rule in rules:
        branched_rule = []
        for i, branch in enumerate(rule['bnf']):
            current_rule = []
            for subrule in branch:
                subrule_name = subrule
                if subrule[-1] == '*':
                    subrule_name = subrule[:-1]
                elif subrule[-1] == '+':
                    subrule_name = subrule[:-1]
                elif subrule[-1] == '?':
                    subrule_name = subrule[:-1]

                if subrule in index:
                    current_rule.append(["goto", subrule])
                else:
                    current_rule.append(["terminal", subrule])
            branch_name = rule['name'] + str(i)
            parsing_states[branch_name] = current_rule
            branched_rule.append(["try", branch_name])
        parsing_states[rule['name']] = ["branch", branched_rule]
    return parsing_states

parsing_table = build_parsing_table([
    {
        "name": "START",
        "bnf": [
            ["STRING"],
            ["NUMBER"],
        ]
    },
    {
        "name": "STRING",
        "bnf": [
            ['"any_string"']
        ]
    },
    {
        "name": "NUMBER",
        "bnf": [
            ["0"],
            ["1"],
            ["2"],
            ["3"],
            ["4"],
            ["5"],
            ["6"],
            ["7"],
            ["8"],
            ["9"],
        ]
    }
])

from pprint import pprint
pprint(parsing_table)

def parse_recursive_descent(input, parsing_table):
    def parse_rule(rule_name):
        rule = parsing_table[rule_name]
        for subrule in rule:
            if subrule[0] == "goto":
                if not parse_rule(subrule[1]):
                    return False
            elif subrule[0] == "terminal":
                if input and input[0] == subrule[1]:
                    input = input[1:]
                else:
                    return False
            elif subrule[0] == "try":
                if not parse_rule(subrule[1]):
                    return False
        return True

    return parse_rule("START")


input = ['"any_string"']
input = ['"any_sadstring"', '#@!2']

print(parse_recursive_descent(input, parsing_table))

# def parse(input, parsing_table):
#     stack = ["START"]
#     while stack:
#         current_state = stack.pop()
#         if current_state in parsing_table:
#             state = parsing_table[current_state]
#             if state[0] == "branch":
#                 stack.append(branch)
#             elif state[0] == "goto":
#                 stack.append(state[1])
#             elif state[0] == "terminal":
#                 if input and input[0] == state[1]:
#                     input = input[1:]
#                 else:
#                     return False
#             elif state[0] == "try":
#                 stack.append(state[1])
#         else:
#             return False

# print(parse(input, parsing_table))
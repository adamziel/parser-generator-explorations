import re

# Read the contents of the grammar-pure.ohm file
with open('mysql_base.ebnf', 'r') as file:
    content = file.read()


def to_snake_case(word):
    is_word_upper = word.isupper()
    if is_word_upper:
        return "symbol_" + word.lower()
    new_word = ''
    upper_streak = False
    for i in range(len(word)):
        char = word[i]
        if char.isupper():
            if i > 0 and not upper_streak and new_word[-1] != '_':
                new_word += '_'
            upper_streak = True
        else:
            upper_streak = False
        new_word += char.lower()
    return new_word

# Find all words at the beginning of a line
matches = re.findall(r'^\s*([a-zA-Z0-9_]{2,})\b', content, re.MULTILINE)

# Replace all occurrences of such words, even those that are not at the beginning of a line
modified_content = content
for match in matches:
    snake_case = to_snake_case(match)
    print(snake_case)
    modified_content = re.sub(r'\b' + match + r'\b', snake_case, modified_content)

# Iterate through the file line by line
lines = modified_content.split('\n')
for i in range(len(lines)):
    line = lines[i]
    # Look for a "|" symbol that's not inside any parenthesis
    parenthesis_depth = 0
    seen_colon = False
    past_first_branch = False
    for char in line:
        if seen_colon and char not in [' ', ':', '|']:
            past_first_branch = True
        if char == '(':
            parenthesis_depth += 1
        elif char == ')':
            parenthesis_depth -= 1
        elif char == '|':
            if parenthesis_depth == 0 and past_first_branch:
                modified_line = re.sub(r': ', ': | ' , line)
                lines[i] = modified_line
                break
        elif char == ':':
            seen_colon = True
    
# Join the modified lines back into a single string
modified_content = '\n'.join(lines)
modified_content = modified_content.replaceAll('| |', '|')
# Write the modified content back to the file
with open('mysql_updated.lark', 'w') as file:
    file.write(modified_content)

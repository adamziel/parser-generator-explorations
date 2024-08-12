import re

# Read the contents of the grammar-pure.ohm file
with open('mysql_base.ebnf', 'r') as file:
    content = file.read()

# Find all words at the beginning of a line
matches = re.findall(r'^\s*([a-zA-Z0-9_]+)\b', content)

def to_snake_case(word):
    return re.sub(r'(?<!^)(?=[A-Z0-9])(?<![A-Z])', '_', word).lower()

# Replace all occurrences of such words, even those that are not at the beginning of a line
modified_content = content
for match in matches:
    snake_case = to_snake_case(match)
    modified_content = re.sub(r'\b' + match + r'\b', snake_case, modified_content, flags=re.IGNORECASE)

# Iterate through the file line by line
lines = modified_content.split('\n')
for i in range(len(lines)):
    line = lines[i]
    # Look for a "|" symbol that's not inside any parenthesis
    parenthesis_depth = 0
    for char in line:
        if char == '(':
            parenthesis_depth += 1
        elif char == ')':
            parenthesis_depth -= 1
        elif char == '|':
            if parenthesis_depth == 0:
                modified_line = re.sub(r': ', ': | ' , line)
                lines[i] = modified_line
                break
    
# Join the modified lines back into a single string
modified_content = '\n'.join(lines)

# Write the modified content back to the file
with open('mysql_updated.lark', 'w') as file:
    file.write(modified_content)

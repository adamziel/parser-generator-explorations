import re

# Read the contents of the grammar-pure.ohm file
with open('src/grammar-pure.ohm', 'r') as file:
    content = file.read()

# Find all words at the beginning of a line starting with a lowercase letter
matches = re.findall(r'(?<=\n)([a-zA-Z]\w+)', content)

# Replace all occurrences of such words, even those that are not at the beginning of a line
modified_content = content
for match in matches:
    uc_match = match[0].upper() + match[1:]
    modified_content = re.sub(r'\b' + match + r'\b', uc_match, modified_content, flags=re.IGNORECASE)

# Write the modified content back to the file
with open('src/grammar-pure-next.ohm', 'w') as file:
    file.write(modified_content)

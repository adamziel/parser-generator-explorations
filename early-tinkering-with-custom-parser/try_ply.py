import ply.yacc as yacc

# JSON Grammar using PLY
tokens = (
    'STRING',
    'NUMBER',
    'TRUE',
    'FALSE',
    'NULL',
    'LBRACE',    # '{'
    'RBRACE',    # '}'
    'LBRACKET',  # '['
    'RBRACKET',  # ']'
    'COLON',     # ':'
    'COMMA'      # ','
)

# Define the JSON grammar rules
precedence = ()

def p_value(p):
    '''value : STRING
             | NUMBER
             | TRUE
             | FALSE
             | NULL
             | object
             | array'''
    pass

def p_object(p):
    '''object : LBRACE RBRACE
              | LBRACE members RBRACE'''
    pass

def p_members(p):
    '''members : STRING COLON value
               | members COMMA STRING COLON value'''
    pass

def p_array(p):
    '''array : LBRACKET RBRACKET
             | LBRACKET elements RBRACKET'''
    pass

def p_elements(p):
    '''elements : value
                | elements COMMA value'''
    pass

def p_error(p):
    print('Syntax error in input!')

# Build the parser
parser = yacc.yacc()

# Access the parsing table
print(dir(parser))
# print(parser.productions)
# print(parser.goto)

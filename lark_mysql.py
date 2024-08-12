from lark import Lark

with open('MySQLParser.ebnf', 'r') as file:
   grammar = file.read()

l = Lark(grammar)
# print( l.parse("Hello, World!") )

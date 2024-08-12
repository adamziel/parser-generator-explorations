%lex
%%
\s+                   /* skip whitespace */
\"([^\\\"]|\\.)*\"    return 'STRING'
"true"                return 'TRUE'
"false"               return 'FALSE'
"null"                return 'NULL'
"{"                   return '{'
"}"                   return '}'
"\["                  return '['
"\]"                  return ']'
","                   return ','
":"                   return ':'
<<EOF>>               return 'EOF'
.                     return 'INVALID'
/lex

%start value

%%

value
    : STRING
    | NUMBER
    | object
    | array
    | TRUE  { $$ = true; }
    | FALSE { $$ = false; }
    | NULL  { $$ = null; }
    ;

object
    : '{' pair_list '}' { $$ = {}; for (var i = 0; i < $2.length; i++) { $$[$2[i].key] = $2[i].value; } }
    ;

pair_list
    : pair
    | pair_list ',' pair { $$ = $1; $1.push($3); }
    | /* empty */ { $$ = []; }
    ;

pair
    : STRING ':' value { $$ = { key: $1, value: $3 }; }
    ;

array
    : '[' value_list ']' { $$ = $2; }
    ;

value_list
    : value
    | value_list ',' value { $$ = $1; $1.push($3); }
    | /* empty */ { $$ = []; }
    ;

STRING
    : '"' ([^"] | '\\"')* '"' { $$ = yytext.substring(1, yytext.length - 1); }
    ;

NUMBER
    : [0-9]+(\.[0-9]+)? { $$ = parseFloat(yytext); }
    ;

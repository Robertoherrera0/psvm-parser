grammar Parser;

tokens {
    INDENT,
    DEDENT
}

program : (statement | NEWLINE)* statement? EOF ;

statement
    : assignment
    | if_statement
    | while_statement
    | for_statement
    | NEWLINE
    ;

// Assignments
assignment : ID ASSIGNMENT definition NEWLINE;

// Conditionals
expression
    : or_expr
    ;

or_expr
    : and_expr (OR and_expr)*
    ;

and_expr
    : not_expr (AND not_expr)*
    ;

not_expr
    : NOT not_expr
    | comparison
    ;

comparison
    : addition (COMPARISON addition)?
    ;


// Nested code blocks
block : NEWLINE INDENT statement+ DEDENT ;

// If-else statements
if_statement : 'if' expression ':' block (NEWLINE elif_statement)? ;
elif_statement : 'elif' expression ':' block (NEWLINE else_statement)? ;
else_statement : 'ELSE' ':' block ;

// Iteration
range_call : RANGE '(' arguments ')' ;
iterable
    : ID
    | array
    | range_call
    ;
while_statement : WHILE or_expr ':' block ;
for_statement : FOR ID IN iterable ':' block ;

// Arithmetic operators
addition
    : multiplication (('+' | '-') multiplication)*
    ;

multiplication
    : value (('*' | '/' | '%') value)*
    ;

value
    : '(' expression ')'
    | ID
    | NUMBER
    | STRING
    | TRIPLE_STRING
    | TRUE
    | FALSE
    | array
    | range_call
    ;

// Type definitions
definition : expression | array | string ;

array
    : '[]'
    | '[' array_values ']'
    ;
array_values : (definition ',')* definition ;

string : STRING;

arguments : or_expr (',' or_expr)* ;

// Lexer Rules
NEWLINE : '\r'? '\n' ;
WS : [ \t]+ -> skip;

COMMENT : '#' ~[\r\n]* -> skip ;

// Strings
STRING
    : '"' (~["\n\r])* '"'
    | '\'' (~['\n\r])* '\''
    ;

// Multi-line comments
TRIPLE_STRING
    : '\'\'\'' .*? '\'\'\''
    | '"""'    .*? '"""'
    ;

// Numbers
NUMBER : '-'? [0-9]+ ('.' [0-9]+)? ;

// Keywords
IF : 'if';
ELIF: 'elif';
ELSE : 'else';

// Boolean
TRUE : 'True';
FALSE : 'False';
AND : 'and';
OR  : 'or';
NOT : 'not';

// Loops
WHILE : 'while';
FOR   : 'for';
IN    : 'in';
RANGE : 'range';

// Assignment operators
ASSIGNMENT : ('+' | '-' | '*' | '/' )? '=' ;

// Comparison operators
COMPARISON : '<=' | '>=' | '==' | '!=' | '<' | '>' ;

// Identifiers
ID : [a-zA-Z_][a-zA-Z_0-9]* ;

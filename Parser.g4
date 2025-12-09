grammar Parser;

program : (statement NEWLINE | NEWLINE)* statement? EOF ;

// Assignments
assignment : ID ASSIGNMENT definition;

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

// If statements
if_else_statement
    : (IF | ELIF) expression ':'
    | ELSE ':'
    ;

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

while_statement
    : WHILE (expression | '(' expression ')') ':'
    ;

for_statement
    : FOR ID IN iterable ':'
    ;

iterable
    : ID
    | array
    | range_call
    ;

range_call
    : RANGE '(' arguments ')'
    ;

arguments
    : expression (',' expression)*
    ;

statement
    : assignment
    | expression
    | if_else_statement
    | while_statement      
    | for_statement        
    | increase_scope
    ;

increase_scope
    : TAB+ statement
    ;

// Whitespace
TAB: '\t';
NEWLINE: '\n';
WS : [ \r]+ -> skip ;

// Comments
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
ELSE : 'else';
ELIF: 'elif';

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

grammar Parser;

program : statement+ EOF ;

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
    | TRUE
    | FALSE
    | array
    ;

// Type definitions
definition : expression | array | string ;

array : '[' array_values ']';
array_values : (definition ',')* definition ;

string : STRING;

statement
    : assignment
    | expression
    ;

WS : [ \t\r\n]+ -> skip ;

ASSIGNMENT : ('+' | '-' | '*' | '/' )? '=' ;
STRING : ('"' | '\'') ~[\\\r\n'"]* ('"' | '\'');
NUMBER  : [0-9]+ ('.' [0-9]+)? ;

// Boolean
TRUE : 'True';
FALSE : 'False';
AND : 'and';
OR  : 'or';
NOT : 'not';

// Comparison operators
COMPARISON : '<=' | '>=' | '==' | '!=' | '<' | '>' ;

ID : [a-zA-Z_][a-zA-Z_0-9]* ;

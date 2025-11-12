grammar Parser;

program : assignment+ EOF ;

// Assignments
assignment : ID ASSIGNMENT_OPERATOR definition;

// Arithmetic operators
expression
    : expression ('*' | '/' | '%') expression
    | expression ('+' | '-') expression
    | '(' expression ')'
    | ID
    | NUMBER
    ;

// Type definitions
definition : expression | array | string ;

array : '[' array_list ;
array_list
    : (expression | string) ']'
    | (expression | string) ',' array_list
    ;

string : STRING;


WS : [ \t\r\n]+ -> skip ;

ASSIGNMENT_OPERATOR : ('+' | '-' | '*' | '/' )? '=' ;
STRING : ('"' | '\'') ~[\\\r\n'"]* ('"' | '\'');
NUMBER  : [0-9]+ ('.' [0-9]+)? ;

ID      : [a-zA-Z_][a-zA-Z_0-9]* ;

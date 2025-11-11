grammar Parser;

program : expression+ EOF ;

// Arithmetic operators
expression
    : expression ('*' | '/' | '%') expression
    | expression ('+' | '-') expression
    | '(' expression ')'
    | ID
    | NUMBER
    ;

ID      : [a-zA-Z_][a-zA-Z_0-9]* ;
NUMBER  : [0-9]+ ('.' [0-9]+)? ;
WS      : [ \t\r\n]+ -> skip ;

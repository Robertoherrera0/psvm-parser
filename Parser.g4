grammar Parser;

tokens {
    INDENT,
    DEDENT
}

@lexer::header {
    import org.antlr.v4.runtime.*;
}
@lexer::members {
    private java.util.LinkedList<Token> pending = new java.util.LinkedList<>();
    private java.util.Stack<Integer> indents = new java.util.Stack<>();
    private int last_token_type = -1;
    private boolean atLineStart = true;

    private CommonToken makeDedent() {
        CommonToken t = new CommonToken(DEDENT, "");
        t.setLine(_tokenStartLine);
        t.setCharPositionInLine(_tokenStartCharPositionInLine);
        return t;
    }
    private CommonToken makeIndent(String text) {
        CommonToken t = new CommonToken(INDENT, text);
        t.setLine(_tokenStartLine);
        t.setCharPositionInLine(_tokenStartCharPositionInLine);
        return t;
    }

    @Override
    public org.antlr.v4.runtime.Token nextToken() {
        if (!pending.isEmpty()) {
            return pending.poll();
        }

        org.antlr.v4.runtime.Token t = super.nextToken();
        if (!pending.isEmpty()) {
            return pending.poll();
        }

        Token t = super.nextToken();
        if (t.getType() == EOF) {
            // Emit needed DEDENTs at end of file
            while (!indents.isEmpty()) {
                indents.pop();
                pending.add(makeDedent());
            }
            pending.add(t);
            return pending.poll();
        }

        last_token_type = t.getType();
        return t;
    }

    private void handleIndentation(String whitespace) {
        int indent = 0;
        for (char c : whitespace.toCharArray()) {
            indent += (c == '\t') ? 8 : 1;
        }

        int prev = !indents.isEmpty() ? indents.peek() : 0;
        if (indent > prev) {
            indents.push(indent);
            pending.add(makeIndent(whitespace));
        }
        else if (indent < prev) {
            while (!indents.isEmpty() && indents.peek() > indent) {
                indents.pop();
                pending.add(makeDedent());
            }
        }
    }
}

program : (statement | NEWLINE)* statement? EOF ;

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


// Nested code blocks
block : NEWLINE INDENT statement+ DEDENT ;

// If-else statements
if_statement : IF expression ':' block (NEWLINE elif_statement)? ;
elif_statement : ELIF expression ':' block (NEWLINE else_statement)? ;
else_statement : ELSE ':' block ;


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
    | if_statement
    | while_statement
    | for_statement
    ;

// Whitespace
NEWLINE : '\r'? '\n' { atLineStart = true; };
LEADING_WS : { atLineStart }? [ \t]+ { 
        atLineStart = false;
        handleIndentation(getText()); 
        skip();
    } ;
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

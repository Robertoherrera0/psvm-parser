grammar Parser;

@lexer::header {
    import java.util.*;
}

@lexer::members {
    Integer currentIndent = 0;
    private final Queue<Token> tokenQueue = new LinkedList<>();
    private boolean atLineStart = true;
    private boolean debug = false;

    @Override
    public Token nextToken() {
        if (!tokenQueue.isEmpty()) {
            Token t = tokenQueue.poll();
            if (debug) System.out.println("DEQUEUE: " + getTokenName(t));
            return t;
        }

        if (atLineStart) {
            atLineStart = false;
            return handleIndentation();
        }

        Token next = super.nextToken();
        if (debug) System.out.println("RAW TOKEN: " + getTokenName(next));
        
        if (next.getType() == EOF) {
            // Add trailing newline
            if (debug) System.out.println("Adding newline to EOF");
            tokenQueue.add(createToken(ParserParser.NEWLINE, ""));

            if (debug) System.out.println("EOF; currentIndent: " + currentIndent);
            while (currentIndent > 0) {
                currentIndent--;
                if (debug) System.out.println("Adding DEDENT at EOF");
                tokenQueue.add(createToken(ParserParser.DEDENT, ""));
            }

            if (!tokenQueue.isEmpty()) {
                tokenQueue.add(next);
                return tokenQueue.poll();
            }
            return next;
        }

        if (next.getType() == NEWLINE) {
            atLineStart = true;
        }

        return next;
    }
    
    private Token handleIndentation() {
        int indent = 0;
        int start = _input.index();
        
        // Count spaces and tabs
        while (true) {
            int c = _input.LA(1);
            if (c == '\t') {
                indent++;
                _input.consume();
            }
            else {
                break;
            }
        }
        
        // Check for EOF
        int c = _input.LA(1);
        if (c == IntStream.EOF) {
            if (debug) System.out.println("EOF at line start");
            while (currentIndent > 0) {
                currentIndent -= 1;
               if (debug) System.out.println("Creating DEDENT at EOF");
                tokenQueue.add(createToken(ParserParser.DEDENT, ""));
            }
            tokenQueue.add(createToken(EOF, ""));
            return tokenQueue.poll();
        }
        
        if (debug) System.out.println("Line start: indent=" + indent + ", current=" + currentIndent);
        
        if (indent > currentIndent) {
            while (indent > currentIndent) {
                currentIndent++;
                if (debug) System.out.println("Adding INDENT");
                tokenQueue.add(createToken(ParserParser.INDENT, ""));
            }
        }
        else if (indent < currentIndent) {
            while (indent < currentIndent) {
                currentIndent--;
                if (debug) System.out.println("Adding DEDENT");
                tokenQueue.add(createToken(ParserParser.DEDENT, ""));
            }
        }
        
        if (!tokenQueue.isEmpty()) {
            return tokenQueue.poll();
        }
        
        return super.nextToken();
    }
    
    private String getTokenName(Token t) {
        String name = ParserParser.VOCABULARY.getSymbolicName(t.getType());
        if (name == null) name = ParserParser.VOCABULARY.getLiteralName(t.getType());
        if (name == null) name = "UNKNOWN";
        return String.format("%s '%s' (line %d, col %d)", 
            name, t.getText().replace("\n", "\\n").replace("\r", "\\r"), 
            t.getLine(), t.getCharPositionInLine());
    }

    private Token handleNewline(Token newlineToken) {
        Token peek = super.nextToken();
        if (debug) System.out.println("After NEWLINE, peeked: " + getTokenName(peek));
        
        // Skip blank lines and comments
        while (peek.getType() == NEWLINE) {
            newlineToken = peek;
            peek = super.nextToken();
            if (debug) System.out.println("Skipping blank line, next peek: " + getTokenName(peek));
        }

        if (peek.getType() == EOF) {
            if (debug) System.out.println("EOF after newline");
            tokenQueue.add(newlineToken);
            tokenQueue.add(peek);
            return tokenQueue.poll();
        }

        // Get indentation level from column position
        int indent = peek.getCharPositionInLine();
        
        if (debug) System.out.println("Indent: " + indent + ", Current: " + currentIndent);
        
        tokenQueue.add(newlineToken);

        if (indent > currentIndent) {
            while (indent > currentIndent) {
                currentIndent++;
                if (debug) System.out.println("Adding INDENT");
                tokenQueue.add(createToken(ParserParser.INDENT, ""));
            }
        }
        else if (indent < currentIndent) {
            while (currentIndent > indent) {
                currentIndent--;
                if (debug) System.out.println("Adding DEDENT");
                tokenQueue.add(createToken(ParserParser.DEDENT, ""));
            }
            if (currentIndent == 0) {
                throw new RuntimeException("Indentation error at line " + peek.getLine());
            }
        }

        tokenQueue.add(peek);
        return tokenQueue.poll();
    }

    private Token createToken(int type, String text) {
        CommonToken token = new CommonToken(type, text);
        token.setLine(getLine());
        token.setCharPositionInLine(getCharPositionInLine());
        return token;
    }

    @Override
    public void reset() {
        currentIndent = 0;
        tokenQueue.clear();
        atLineStart = true;
        super.reset();
    }
}

tokens {
    INDENT,
    DEDENT
}

program : statement* EOF ;

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
    : '(' value ')' // done this way to try to take a shortcut, instead of having or_expr->and_expr->not_expr->...->value
    | value
    | '(' arithmetic ')'
    | arithmetic
    | '(' comparison ')'
    | comparison
    | '(' not_expr ')'
    | not_expr
    | '(' and_expr ')'
    | and_expr
    | '(' or_expr ')'
    | or_expr
    ;

or_expr
    : sub_or_expr (OR sub_or_expr)*
    ;
sub_or_expr
    : value
    | arithmetic
    | comparison
    | not_expr
    | and_expr
    ;

and_expr
    : sub_and_expr (AND sub_and_expr)*
    ;
sub_and_expr
    : value
    | arithmetic
    | comparison
    | not_expr
    ;

not_expr
    : NOT sub_not_expr
    | comparison
    ;
sub_not_expr
    : value
    | arithmetic
    | comparison
    | not_expr
    ;

comparison
    : arithmetic (COMPARISON arithmetic)?
    ;


// Nested code blocks
block : INDENT statement+ DEDENT ;

// If-else statements
if_statement : IF expression ':' NEWLINE block elif_statement* else_statement?;
elif_statement : ELIF expression ':' NEWLINE block;
else_statement : ELSE ':' NEWLINE block ;

// Iteration
range_call : RANGE '(' arguments ')' ;
iterable
    : ID
    | array
    | range_call
    ;
while_statement : WHILE expression ':' NEWLINE block ;
for_statement : FOR ID IN iterable ':' NEWLINE block ;

// Arithmetic operators
arithmetic
    : value
    | multiplication
    | addition
    ;

addition
    : (value | multiplication) (('+' | '-') (value | multiplication))*
    ;

multiplication
    : value (('*' | '/' | '%') value)*
    ;

value
    : '(' expression ')'
    | ID
    | NUMBER
    | STRING
    | MULTILINE_COMMENT
    | TRUE
    | FALSE
    | array
    | range_call
    ;

// Type definitions
definition : value | expression | array | string ;

array
    : '[]'
    | '[' array_values ']'
    ;
array_values : (definition ',')* definition ;

string : STRING;

arguments : or_expr (',' or_expr)* ;

// Lexer Rules
NEWLINE : '\r'? '\n' ;
WS : [ ]+ -> skip;

// Comments
COMMENT : '#' ~[\r\n]* -> skip ;
MULTILINE_COMMENT
    : ('\'\'\'' .*? '\'\'\'' | '"""' .*? '"""') -> skip ;

// Strings
STRING
    : '"' (~["\n\r])* '"'
    | '\'' (~['\n\r])* '\''
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

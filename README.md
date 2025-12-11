# Psvm-Parser
CS4450 - Parser Project - Public Static Void Main Group

This project implements a parser for the Python 3.x language using a context-free grammar written for ANTLR 4.13.2. The parser is generated in Java.
It supports arithmetic expressions, assignments, conditionals, loops, indentation-based block structure, and single-line and multi-line comments

The output of the parser is an ANTLR-generated parse tree, viewable as plain text or as an image.

### Team Members
- Roberto Herrera
- Greyson Rockwell

## Setup and Requirements
You need Java 11+

Download ANTLR 4.13.2:

`curl -O https://www.antlr.org/download/antlr-4.13.2-complete.jar`

## How to Run

Before running, ensure `antlr-4.13.2-complete.jar` is in the project directory and set classpath

`export CLASSPATH=".;antlr-4.13.2-complete.jar;build;$CLASSPATH"`

### Using the Script

This script rebuilds the parser and runs it on `project_deliverable_3.py`.

Text output: `./run.sh -tree`

GUI output: `./run.sh -gui`

If no argument are given, it defaults to `-tree`

### Manual Execution

Generate parser and lexer

`java -jar antlr-4.13.2-complete.jar -Dlanguage=Java Parser.g4 -o build`

Compile

`javac build/*.java`

Generate parse tree as text

`java org.antlr.v4.gui.TestRig Parser program -tree project_deliverable_3.py`

Generate parse tree as image

`java org.antlr.v4.gui.TestRig Parser program -gui project_deliverable_3.py`

## Demo


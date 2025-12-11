#!/bin/bash

MODE="-tree"
FILE="project_deliverable_3.py"

if [ "$1" == "-gui" ]; then
    MODE="-gui"
elif [ "$1" == "-tree" ]; then
    MODE="-tree"
fi

rm -rf build
mkdir build

echo "Generating lexer and parser..."
java -jar antlr-4.13.2-complete.jar -Dlanguage=Java Parser.g4 -o build

echo "Compiling..."
javac build/*.java

echo "Running parser $MODE..."
java org.antlr.v4.gui.TestRig Parser program $MODE $FILE

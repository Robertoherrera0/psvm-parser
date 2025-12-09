# export path class first
rm -rf build

java -jar antlr-4.13.2-complete.jar -Dlanguage=Java Parser.g4 -o build

javac build/*.java

java org.antlr.v4.gui.TestRig Parser program -tree project_deliverable_3.py

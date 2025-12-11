# psvm-parser
CS4450 - Parser Project - Public Static Void Main Group

## Setup
You need Java 11+

Download ANTLR 4.13.2:

```curl -O https://www.antlr.org/download/antlr-4.13.2-complete.jar```


## How to Run

Set classpath

```export CLASSPATH=".;antlr-4.13.2-complete.jar;build;$CLASSPATH"```

### Using the Script
Run the .sh file

```./run.sh```

### Manually
Generate parser and lexer

```java -jar antlr-4.13.2-complete.jar -Dlanguage=Java Parser.g4 -o build```

Compile

```javac build/*.java```

Generate parse tree as text

```java org.antlr.v4.gui.TestRig Parser program -tree project_deliverable_1.py```

Generate parse tree as image

```java org.antlr.v4.gui.TestRig Parser program -gui project_deliverable_1.py```

# psvm-parser
CS4450 - Parser Project - Public Static Void Main Group

## Setup
You need Java 11+
Download ANTLR 4.13.2:
curl -O https://www.antlr.org/download/antlr-4.13.2-complete.jar


## How to Run
```java -jar antlr-4.13.2-complete.jar -Dlanguage=Java -visitor -no-listener Parser.g4 -o build```

```javac -cp ".;antlr-4.13.2-complete.jar;build" build/*.java```

```java -cp ".;antlr-4.13.2-complete.jar;build" org.antlr.v4.gui.TestRig Parser program -tree project_deliverable_1.py```

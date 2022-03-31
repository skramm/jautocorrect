# jautocorrect

Student Java code autocorrect

(This is work in progress !)


## Goal: automate testing of student Java programs

- Input: zip file downloaded from a Moodle instance
- Output: a csv file holding results of tests for each assignement/student

## Context
Students are given an assignment:
they need to write a small (single) Java program that generates some console output.
When they are done, they upload the unique source file on a Moodle instance.

They are multiple assignments (so every student does not have the same), identified by an index.
Thus, the file they are required to upload must have a filename similar to:
`MyProgram1.java` or `Assignment5.java` or `Exercice3.java`



## What this program does:

- extract zip file into `src` folder
- for each file:
    - extract student name and number from file name
    - extract assignment index from file name
    - checks that assignment index is correct (is an authorized one). If not, report it.
    - checks that filename is correct (is the one given in assignment). If not, report it.
    - checks that file extension is correct (is the one given in assignment). If not, report it. 
    - checks that program compiles (`javac`), if not report is in output file and switch to next
    - runs the provided test scripts, compare (`cmp`) the generated output with the provided output it should generate, on count the number of success. Report that count.

## Input file
The input zip file is assumed to contains files matching the pattern:
```
PPPPP NNNNN_XXXXXXX_assignsubmission_file_FFFFFC.EEE
```
with:

- PPPPP: firstname
- NNNNN: lastname
- XXXXXXX: student number
- FFFFF: file name (given in assignment)
- C: index of assignment
- EEE: file extension (java, here)

This format is given by my local Moodle instance/version, it might not be the same for you.


## What do I need to do as teacher ?

You need to:

  1. edit the script and change variables `FILE` and `INDEXES` as required
  2. provide the test scripts
  3. provide the expected output for each line of the test scripts

Each program is tested with different arguments, these need to be given for each assignment index in a file named `args1.txt` (or `args2.txt` for index=2, `args3.txt` for index=3,...).
These files will hold the command line arguments to be given, with as first element the number of arguments.
Comments may be given by putting `#` as first character, empty lines are allowed.

For example, this file:
```
0
2 A 42
```
will generated two runs of the program, one with no arguments, the other with 2 arguments, i.e. if the program name is `Abc.java` and the assignement index is 5, then this is equivalent to running:
```
$ java Abc5.java > stdout50.txt
$ java Abc5.java a 42 > stdout51.txt
```
## Tips

Point 3 above can be quite tedious. So what you can do is try a "dry run" without any files in the `expected/` folder and use the output by a given student (that you will find in the 
`exec/` folder).

## I don't get it. You have a demo to show me?

(TODO)

## Possibly / vaguely related stuff

- https://github.com/fpom/badass
- https://cseducators.stackexchange.com/questions/1205/how-can-i-automate-the-grading-of-programming-assignments
- https://web-cat.org/


  


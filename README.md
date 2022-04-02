# jautograde

Student Java code automatic grading

(This is work in progress !)



## Goal: automate testing of student Java programs

- Input: zip file downloaded from a Moodle instance
- Output: a csv file holding results of tests for each assignement/student
- Usage: `./jautocorrect.sh [flags] input_file.zip`

## Context
Students are given an assignment:
they need to write a small (single file) Java program that generates some console output, given some command-line arguments.
When they are done, they upload the unique source file on a Moodle instance.

There are multiple assignments (so every student does not have the same), identified by an index.
Thus, the file they are required to upload must have a filename similar to:
`MyProgram1.java` or `Assignment5.java` or `Exercice3.java`

This bash script will automate the testing of each program, to see if it fullfilths the requirements that the given arguments produces a given output.

**Warning**
Parsing the produced output is a byte-to-byte comparison (`cmp` shell command).
So if you expect an output to be, say, `Abc!` and the student programs outputs `Abc !`, this will count as a failure.

## What this program does:

- extract input zip file into `src/` folder
- for each file:
    - extract student name and number from file name
    - extract assignment index from file name
    - checks that assignment index is correct (is an authorized one). If not, report it and switch to next one.
    - checks that filename is correct (is the one given in assignment). If not, report it, and carry on.
    - checks that file extension is correct (is the one given in assignment). If not, report it, and carry on. 
    - checks that program compiles (`javac`), if not report is in output file and switch to next one.
    - runs the provided test scripts, compare (`cmp`) the generated output with the provided output it should generate, and count the number of success. Report that count.

## Input file
The input zip file is assumed to contains a set of files matching the pattern:
```
PPPPP NNNNN_XXXXXXX_assignsubmission_file_FFFFFC.EEE
```
with:

- PPPPP: firstname
- NNNNN: lastname
- XXXXXXX: student number
- FFFFF: file name (given in assignment)
- C: index of assignment (single digit)
- EEE: file extension (java, here)

This format is given by my local Moodle instance/version, it might not be the same for you.

## Flags

  - `-n`: no checking of produced output files
  - `-s`: stops after processing each program

The parser is pretty basic, so the flags must be given separately (but in any order), thus this will fail:
```
./jautograde -ns input.zip
```
but this is ok:
```
./jautograde -n -s input.zip
```


## What do I need to do as teacher ?

You need to:

  1. edit the script and change variables `FILE`, `INDEXES`, `NBTESTS` as required;
  2. provide the test data;
  3. provide the expected output for each line of the test scripts.

Each program is tested with different arguments, these need to be given for each assignment index in a file named `args1.txt` (or `args2.txt` for index=2, `args3.txt` for index=3,...), located in folder `input_args/`.
These files will hold the command line arguments to be given, with as first element the number of arguments.
Comments may be given by putting # as first character, empty lines are allowed.

For example, this file content:
```
0
2 A 42
```
will generated two runs of the program, one with no arguments, the other with 2 arguments, i.e. if the program name is `Abc` and the assignement index is 5, then this is equivalent to running this in the `exec/` folder:
```
$ java Abc5.java > stdout50.txt
$ java Abc5.java a 42 > stdout51.txt
```
Once this is done, the script will then compare the generated output files with the ones having the same name, in folder `expected/`.


## Tips

Point 3 above can be quite tedious. So what you can do is try a "dry run" without any files in the `expected/` folder and use the output by a given student (that you will find in the 
`exec/` folder).

## I don't get it. You have a demo to show me?

(TODO)

## Possibly / vaguely related stuff

- https://github.com/fpom/badass
- https://cseducators.stackexchange.com/questions/1205/how-can-i-automate-the-grading-of-programming-assignments
- https://web-cat.org/


  


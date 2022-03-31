# jautocorrect

Student Java code autocorrect
(work in progress !)

## Goal: automate testing of student Java programs

- Input: zip file downloaded from a Moodle instance
- Output: a csv file holding results of test for each student

## Context
Students are given an assignment:
they need to write a small Java program that generates some console output.
When they are done, they upload the source file on a Moodle instance.

They are multiple assignments, identified by an index.
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
    - runs the provided test scripts
    - if running (`java`) does not return 0, report  it on output file and switch to next
    - compare (`cmp`) generated output with provided template and report the number of discrepancies in output file

The zip file is assumed to contains files matching the pattern:
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

## Possibly/ vaguely related

- https://cseducators.stackexchange.com/questions/1205/how-can-i-automate-the-grading-of-programming-assignments
- https://web-cat.org/
- 

  


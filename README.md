# jautograde

Student Java code automatic grading

(This is work in progress, stable release expected current april 2022)


## Goal: automate testing of student small Java programs

- Input: zip file downloaded from a Moodle instance
- Output: a csv file holding results of tests for each assignement/student
- Usage: `./jautocorrect.sh [options] input_file.zip`

## Context

Students are given an assignment:
they need to write a small (single file) Java program that generates some console output, given some command-line arguments.
When they are done, they upload the unique source file on a Moodle instance.

There are multiple assignments (so every student does not have the same), identified by an index.
Thus, the file they are required to upload must have a filename similar to:
`MyProgram1.java` or `Assignment5.java` or `Exercice3.java`

This bash script will automate the testing of each program, to see if it fullfilths the requirements that the given arguments produces a given output.

This script will generate a CSV file holding firstname, lastname, student id number, and 0 or 1 in following columns, for these items:

 - does the program have the required name?
 - does the program filename hold the assignment index at the correct position (i.e. at the end)?
 - does the program filename hold the correct extension?
 - does the program compile?
 - does the program run and return 0 as return value?
 - does the program generate the correct output for the given arguments?

All of these informations is printed out in the output file that you can further upload into a spreadsheet application to compute a grade according to the points above that you consider relevant.

### Requirements

- A bash shell
- The [GNU diffutils](https://www.gnu.org/software/diffutils/) GNU package (probably already available on your machine).

### Licence

[GNU General Public License, v3](https://www.gnu.org/licenses/gpl-3.0.html)

## What this program does:

- extract input zip file into `src/` folder
- for each file:
    - extract student name and number from file name
    - extract assignment index from file name
    - checks that assignment index is correct (is an authorized one). If not, report it and switch to next one.
    - checks that filename is correct (is the one given in assignment). If not, report it, and carry on.
    - checks that file extension is correct (is the one given in assignment). If not, report it, and carry on. 
    - checks that program compiles (`javac`), if not report it in output file and switch to next one.
    - runs the provided test scripts and checks that return value is 0
    - compare (using the `diff` program) the generated output with the provided output it should generate, and count the number of success. Report that count.

## Input file
The input zip file is assumed to contain a set of files matching the pattern:
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
This could be adjusted.

## Command-line options

  - `-n`: no checking of produced output files
  - `-s`: stops after processing each program
  - `-v`: verbose mode: prints for each test both the expected output(s) and the produced output.
  - `-t`: store the student programs renamed with the extracted name into `exec/stored/<id-number>` (will be cleared by new run)
  - `-l`: change the way names with 3 words are handled (see below).
  - `-p`: show parameters (loaded or default ones) and quit.


The parser is pretty basic, so the flags must be given separately (but in any order), thus this will fail:
```
./jautograde -ns input.zip
```
but this is ok:
```
./jautograde -n -s input.zip
```
#### Other options

Comparison of expected output and generated output is done with the `diff` program.
It has a lot of options that you may use, by storing them into the `diffOptions` variable (see top of program).
One of the most useful (and the default) is probably `-b`, that both ignores trailing spaces and considers multiples space characters as a single one.

For details, see https://www.gnu.org/software/diffutils/manual/diffutils.html#White-Space


#### Names with 3 words

For some reason, it seems that Moodle stores full names only in a single field, as "firstname lastname".
This can be annoying when copying/pasting results to another spreadsheet document, because we usually use last names, and having the first name in first position makes it difficult to sort.

For names with only 2 words ("John Doe"), it's easy to separate them into firstname and lastname into the output csv file.
But for names with 3 words ("John Something Doe"), we run into an issue: is the lastname "Doe" or "Something Doe".
The default behavior is to consider that the lastname is "Something Doe", but you can change that by passing the `-l` switch.
In that case, the lastname will be "Doe" and the firstname "John Something".

Please note that this script actually does not support names with more than 3 words.

## What do I need to do as teacher ?

You need to:

  1. configure the script
  2. provide the test arguments (one file per assignment index);
  3. provide the expected output for each line of the test scripts.

### 1 - Configuration

The general configuration is done through a separate text file named `config.txt`.
Very basic, KEY=VALUE style (see provided one)
If that file is missing, or if a given key is not present, the program will use default ones.

You need to provide:
  - the expected name of the program: `FILE`,
  - the expected indexes: `INDEXES`
  - the number of tests: `NBTESTS`


### 2 - Providing test arguments

Each program is tested with different arguments, these need to be given for each assignment index in a file named `args1.txt` (or `args2.txt` for index=2, `args3.txt` for index=3,...), located in folder `input_args/`.
These files will hold the command line arguments to be given, with as first element the number of arguments.
Comments may be given by putting # as first character, empty lines are allowed.

For example, this file content:
```
0
2 A 42
```
will generate two runs of the program, one with no arguments, the other with 2 arguments, i.e. if the program name is `Abc` and the assignement index is 5, then this is equivalent to running this in the `exec/` folder:
```
$ java Abc5.java > stdout50.txt
$ java Abc5.java A 42 > stdout51.txt
```
Once this is done, the script will then compare the generated output files with the ones having the same name, in folder `expected/`.

### 3 - Providing expected output

For each assignment index and each test case, you need to provide a file named `stdoutXY.txt`
in the `expected` folder, with X the assignment index and Y the test case (corresponding to the given line in file `input_args/argsX.txt`).

To avoid having failures for some minor differences between the expected output and the student program output, you can provide several files holding the different outputs that are accepted.
For example, if you expect an output to be `5` (`int` value) but you consider that the output `5.0` (`float` value) is ok too, then you need to provide two files matching the pattern
`stdoutXY*.txt`.
For example `stdoutXYa.txt` and `stdoutXYb.txt`.


#### Tips

Point 3 above can be quite tedious.
So what you can do is try passing the `-s` flags, and have a look at what the student program generates (in the `exec/` folder).
If it fits, then just copy the files as is to the `expected/` folder!


## Possibly / vaguely related stuff

- https://github.com/fpom/badass
- https://cseducators.stackexchange.com/questions/1205/how-can-i-automate-the-grading-of-programming-assignments
- https://web-cat.org/

## FAQ

### Why ?

Well... I sorted of needed that kinda stuff to avoid checking for really basic stuff when grading the student works.

### I don't get it. You have a demo to show me?

WIP !!

### Why bash ? Why not Python or [name here latest hype language]?

At one point I felt that my bash skills were too rusty. Kinda slow, indeed, but given the context, that shouldn't be a problem.

And bash is stable, so old that it is not expected to have a new breaking release anytime soon.


### Could this be usable with other languages?

Maybe. C or C++, why not, but you might run into issues about passing the compile options (`CFLAGS`, `LDFLAGS`).


### Any chance this will work on Windows?

Can't say. There is some thing called WSL on Windows, maybe you can give it a try.
Please let me know.

### Could this be used independently from Moodle (that is, by directly providing a zip file holding all the programs)?

Yep, that could work but would require some tweaking of the file name extraction.
Please [post an issue](https://github.com/skramm/jautograde/issues) describing your usecase, I'll see if I can fix that.

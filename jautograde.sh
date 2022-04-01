set +x

# homepage: https://github.com/skramm/jautocorrect

# Required filename (without added assignment index)
FILE=Test

# Required filename extension
EXT=java

# autorized assignment indexes: array of arbitrary integer digits
INDEXES=(1 2)

# output log file
OUTFILE=log.csv

# number of tests for each assignement
NBTESTS=4

# compiler (only javac at present)
COMPILER=javac

# interpreter (only java at present)
INTERPRETER=java

#================================================================

function compare
{
	sum1=0
	for i in $(ls expected/stdout$1*.txt)
	do
		fn2=$(basename "$i")
		echo " -comparing with $fn2"
		cmp -s expected/$fn2 exec/$fn2 
		retval=$?
		sum1=$(($sum1+$retval))
	done
	echo "compare score: $sum1"
}

function run_tests
{
	echo "* run_tests, $name, index: $index pwd=$(pwd)"
	input="input_args/args$index.txt"
	itest=0
	while IFS= read -r line
	do
	#	echo "line=$line, char1=${line:0:1}"
		IFS=' ' read -ra ADDR <<< "$line"
		nb=${ADDR[0]}
		
		if [[ ${#line} != 0 ]] && [[ "${line:0:1}" != "#" ]] # only if line is not empty
		then
			echo "nb args=$nb itest=$itest"
			if [ $nb != 0 ]
			then
				args=""
				for (( n=1; n<=$nb; n++ ))
				do
#					echo "n=$n arg= ${ADDR[$n]}"
					args="$args${ADDR[$n]} "
				done
				echo "args=$args"
				cd exec/
				$INTERPRETER $FILE$index.$EXT $args > stdout$index$itest.txt				
				cd ..
			fi
		fi
	itest=$((itest+1))
	done < "$input"

}

function build_tests
{
	echo "* build_tests, $name, index: $index"
	cd exec/;

# compile attempt
	$COMPILER $FILE$index.$EXT 2>/dev/null
	r2=$?
	rm *.class 2>/dev/null
	if [ $r2 = 0 ] # if compile is successful
	then
		printf ",1" >>$OUTFILE
#		echo "-Running tests"
		cd ..
		run_tests
		if [ $noCheck = 0 ]
		then
			compare $index
			printf ",1,%d" $sum1 >>$OUTFILE
		fi
	else
		cd ..
		echo "compile failure!"
		printf ",0" >>$OUTFILE
	fi
}

# ============================================
# START
# ============================================

# 1 - GENERAL CHECKING
if [[ "$1" == "" ]]
then
	echo "usage: ./jautograde input_file.zip [flags]"
	exit 1
fi

if [[ ! -e "$1" ]]
then
	echo "Input file not present!"
	exit 2
fi

noCheck=0
if [[ "$2" != "" ]]
then
	if [[ "$2" = "-s" ]]
	then
		echo "-no checking option activated"
		noCheck=1
	fi
fi


# 2- cleanout previous run and unzip input file
rm src/*
unzip -q "$1" -d src/
nbfiles=$(ls -1| wc -l)
echo "processing $nbfiles input files"

# 3 - CHECKING REQUIRED FILES

for f in ${INDEXES[@]}
do
	argf=input_args/args$f.txt
	if [[ ! -e $argf ]]
	then	
		echo "Missing arguments file '$argf', see manual"
		exit 3
	fi

	if [ $noCheck = 0 ]
	then
		for (( n=1; n<=$NBTESTS; n++ ))
		do
			expected=expected/stdout$f$n.txt
			if [[ ! -e $expected ]]
				then	
					echo "Missing expected results file: '$expected', see manual"
					exit 4
			fi		
		done
	fi
done





echo "# Results" >$OUTFILE
printf "# student name,student number,filename ok,extension ok,compile success,test score\n">>$OUTFILE

# LOOP START
for a in src/*.$EXT
do
	bn=$(basename "$a")
	echo "processing $bn"
	IFS='_' read -ra ADDR <<< "$bn"
	name=${ADDR[0]}
	num=${ADDR[1]}
	na=${ADDR[4]}
	printf "%s,%s" "$name" $num >> $OUTFILE
# separate filename and extension
	na1=${na%.*}
	na2=${na#*.}
# get assignment name and index
	sna=$((${#na1}-1))
	an=${na1:0:sna}
	index=${na1:sna:1}
#	echo "bn=$bn na=$na na1=$na1 na2=$na2 sna=$sna an=$an, index=$index"

# check that filename is correct (if not good, go on anyway)
	if [ "$an" = "$FILE" ]
	then
		printf ",1" >> $OUTFILE
	else
		printf ",0" >> $OUTFILE
	fi

# check that index is correct (if not good, stop, because we can't do more)
	indexok=0
	for i in "${INDEXES[@]}"
	do
		if [ $i = $index ];	then indexok=1; fi
	done

	if [ $indexok = 1 ]
	then
		printf ",1" >> $OUTFILE	
		cp "src/$bn" exec/$FILE$index.$EXT
		echo "DEBUT TEST"
		build_tests
	else
		printf ",0" >> $OUTFILE
		echo "-Failure: incorrect assignment index!"
	fi
	printf "\n" >> $OUTFILE	
	if [ $noCheck = 1 ]
	then
		echo "No Check mode active: hit enter to switch to next file"
		read
	fi
done


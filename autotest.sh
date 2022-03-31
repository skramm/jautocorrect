set +x

# homepage: https://github.com/skramm/jautocorrect

# Required filename (without added assignment index)
FILE=Test

# Required filename extension
EXT=java

# autorized assignment indexes
INDEXES=(1 2)

# output log file
OUTFILE=log.csv

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

function test
{
	echo "* Debut test de $name, exercice: $1"
	cp "src/$bn" exec/$FILE$1.$EXT
	cd exec/;

# tentative de compilation
	javac $FILE$1.$EXT 2>/dev/null
	r2=$?
#	if [ -f $FILE$1.class ]; then rm $FILE$1.class; fi
	rm *.class 2>/dev/null
	if [ $r2 = 0 ]
	then
		echo "-Running tests"
		./test$1.sh
		cd ..
		compare $1
		echo "$name;$num;score=$sum1" >>$OUTFILE
	else
		cd ..
		echo "$name;$num;compile failure" >>$OUTFILE
	fi
}

echo "Bilan" >$OUTFILE
for a in src/*.$EXT
do
	bn=$(basename "$a")

	IFS='_' read -ra ADDR <<< "$bn"
	name=${ADDR[0]}
	num=${ADDR[1]}
	na=${ADDR[4]}
	printf "%s,%s" $name $num >> $OUTFILE
# separate filename and extension
	na1=${na%.*}
	na2=${na#*.}
# get assignment name and index
	sna=$((${#na1}-1))
	an=${na1:0:sna}
	index=${na1:sna:1}
	echo "bn=$bn na=$na na1=$na1 na2=$na2 sna=$sna an=$an, index=$index"

# check that filename is correct
	if [ "$an" = "$FILE" ]
	then
		printf ",1" >> $OUTFILE
	else
		printf ",0" >> $OUTFILE
	fi

# check that index is correct
	indexok=0
	for i in "${INDEXES[@]}"
	do
		if [ $i = $index ]
		then	
			echo "index ok"
			indexok=1
		fi
	done

	if [ $indexok = 1 ]
	then
		printf ",1" >> $OUTFILE	
		cp "src/$bn" exec/$FILE$index.$EXT
		echo "DEBUT TEST"
	else
		printf ",0" >> $OUTFILE
	fi

	read
done


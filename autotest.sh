set +x

# nom fichier extrait de l'archive récupérée via Moodle
# PPPPP NNNNN_XXXXXXX_assignsubmission_file_FFFFFC.EEE
# PPPPP: prénom
# NNNNN: nom
# XXXXXXX: numéro étudiant
# FFFFF: nom fichier
# C: code-index
# EEE: extension fichier

# Paramétrage
FILE=Test
EXT=java
INDEXES=(1 2)

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
		echo "$name;$num;score=$sum1" >>log.txt
	else
		cd ..
		echo "$name;$num;compile failure" >>log.txt
	fi
}

echo "Bilan" >log.txt
for a in src/*.$EXT
do
	bn=$(basename "$a")

	IFS='_' read -ra ADDR <<< "$bn"
	name=${ADDR[0]}
	num=${ADDR[1]}

	if [ ${ADDR[4]} = "${FILE}1.$EXT" ]
	then
		test 1
	else
		if [ ${ADDR[4]} = "${FILE}2.$EXT" ]
		then
			test 2
		else
			echo "$name;$num;Erreur de nom" >> log.txt
		fi
	fi
#	read
done


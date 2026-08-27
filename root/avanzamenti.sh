#!/bin/bash

BASE=/var/www
NPRG=0

. /etc/avanzamenti.conf

source va.txt.progressbar.sh

echo "AVANZAMENTO PROGETTI"
echo "===================="
if [ -f $BASE/notes.md ]; then
    if [ -n "$(cat $BASE/notes.md)" ]; then
        echo "$(cat $BASE/notes.md)"
    fi
fi

printf "%-36s | %-60s | %12s | %12s | %12s | %12s \n" "progetto" "avanzamento" "%" "disall." "fatte" "totale"
printf "%0.s-" {1..36}
printf " | "
printf "%0.s-" {1..60}
printf " | "
printf "%0.s-" {1..12}
printf " | "
printf "%0.s-" {1..12}
printf " | "
printf "%0.s-" {1..12}
printf " | "
printf "%0.s-" {1..12}
echo

SAL=""

for i in $(find $BASE -maxdepth 1 -type d | sort -h); do

    # echo "scansiono $i"
    cd $i

    if [ -f TODO.md ]; then

        DISALLINEAMENTI=$(ls | grep disallineamenti | wc -l)

        if [ $DISALLINEAMENTI -eq 0 ]; then
            DISALLINEAMENTI=""
        fi

        # conteggi ancorati a inizio riga, identici a quelli di cron.daily/burndown:
        # prima qui si usava grep -Fwc, non ancorato, e bastava un marcatore citato a
        # meta' riga o una voce scritta senza il "- " iniziale per far divergere il
        # cruscotto dalla burndown chart
        TODO=$(grep -Ec '^- \[ \]' TODO.md)
        DEEP=$(grep -Ec '^- \[\?\]' TODO.md)
        DONE=$(grep -Ec '^- \[v\]' TODO.md)
        DROP=$(grep -Ec '^- \[x\]' TODO.md)

        # [?] e' aperta e da approfondire: sta con le aperte
        TODO=$((TODO + DEEP))

        TOT=$((TODO + DONE + DROP))

        # si mostra il progetto anche quando non ha piu' nulla di aperto (prima era
        # "TODO -gt 0" e i progetti finiti sparivano dal cruscotto); il guardiano vero
        # e' TOT, perche' progressbar divide per TOT e con un TODO.md vuoto darebbe
        # una divisione per zero in bc
        if [ "$TOT" -gt 0 ]; then

            printf "%-36s " ${i##*/}
            progressbar $((DONE + DROP)) $TOT 60 12
            printf " | "
            printf "%12s" "$DISALLINEAMENTI"
            printf " | "
            printf "%12s" "$((DONE + DROP)) vs. $TODO"
            printf " | "
            printf "%12s" "$TOT"

            if [ -n "$(grep 'SAL PIANIFICATA' TODO.md)" ]; then

                SAL="$SAL$(grep 'SAL PIANIFICATA' TODO.md)"
                SAL=$( echo "$SAL" | sed "s/SAL PIANIFICATA/${i##*/}§/" )

                ((NPRG++))

            fi

#            PROG=$( echo "scale=2 ; $DONE / $TOT" | bc )
#            PERC=$( echo "scale=2 ; $PROG * 100" | bc )
#
#            ## output
#            printf "%-32s |" $i
#            printf '%0.s#' $( seq $DONE )
#            printf '%0.s-' $( seq $TODO )
#            echo " $DONE/$TODO ($PERC%)"

            echo

            ((NPRG++))

        fi

    fi

done

if [ -n "$( echo "$SAL" | sed 's/§/\n/g' | sort -h | head -n 5 | sed '/^$/d' )" ]; then

    echo
    echo "PROSSIME SAL"
    echo "============"
    echo "$SAL" | sed 's/§/\n/g' | sort -h | head -n 5 | sed '/^$/d'

    ((NPRG+=3))

fi

echo
echo "BURNDOWN CHART"
echo "=============="

echo "data            da fare | grafico"
echo "----------------------- | -------------------------------------------------------------------------------------------------------------------------------------"

ROWS=38
ROWS=$((ROWS-NPRG))

if [ -f $BASE/burndown.md ]; then
    tail -n $ROWS $BASE/burndown.md
fi

## NOTA
# qui sfrutto la comodissima caratteristica di sed per cui è possibile utilizzare un separatore diverso da \ facendone l'escape
# al primo utilizzo (\#)
#
# questo gestore delle cose da fare richiede che in /etc/cron.daily sia presente lo script burndown; richiede anche la libreria
# va.txt.progressbar.sh in /usr/bin
#

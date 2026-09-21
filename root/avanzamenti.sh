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

printf "%-36s | %-60s | %12s | %12s | %12s | %12s | %12s \n" "progetto" "avanzamento" "%" "disall." "fatte" "attesa" "totale"
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
printf " | "
printf "%0.s-" {1..12}
echo

SAL=""

for i in $(find $BASE -maxdepth 1 -type d | sort -h); do

    # echo "scansiono $i"
    cd $i

    if [ -f TODO.md ]; then

        # quante voci ci sono davvero da guardare, cioe' quante ne ha messe da parte
        # l'ULTIMA raccolta e sono ancora diverse da quello che c'e' a monte.
        #
        # prima qui c'era 'ls | grep disallineamenti | wc -l', che contava la CARTELLA
        # 'disallineamenti' e non il suo contenuto: valeva 1 per sempre su ogni deploy che
        # ne avesse una e vuoto sugli altri. Non era un conteggio, era un "esiste", e
        # leggendo il cruscotto sembrava che ci fosse sempre una voce aperta da smaltire
        # anche il giorno in cui erano state promosse tutte.
        #
        # si guarda solo l'ultima raccolta perche' e' l'unica che descrive l'adesso: ogni
        # giro notturno ri-raccoglie da capo tutto quello che ancora diverge, mentre le
        # cartelle vecchie restano sul disco 30 giorni ( cron.daily/pulizia-disallineamenti-siti )
        # con dentro roba gia' portata a monte. Sommarle darebbe un numero che non e' mai
        # stato vero in nessun momento.
        #
        # e non si contano i .diff vuoti: sono i file che a monte sono gia' identici, si
        # scartano senza guardarli e non sono lavoro di nessuno
        DISALLINEAMENTI=""

        ULTIMA=$( ls -1d disallineamenti/*/ 2>/dev/null | sort | tail -n 1 )

        if [ -n "$ULTIMA" ]; then

            DISALLINEAMENTI=$( find "$ULTIMA" -type f -name '*.diff' ! -empty | wc -l )

            if [ "$DISALLINEAMENTI" -eq 0 ]; then
                DISALLINEAMENTI=""
            fi

        fi

        # conteggi ancorati a inizio riga, identici a quelli di cron.daily/burndown:
        # prima qui si usava grep -Fwc, non ancorato, e bastava un marcatore citato a
        # meta' riga o una voce scritta senza il "- " iniziale per far divergere il
        # cruscotto dalla burndown chart
        TODO=$(grep -Ec '^- \[ \]' TODO.md)
        WAIT=$(grep -Ec '^- \[=\]' TODO.md)
        DEEP=$(grep -Ec '^- \[\?\]' TODO.md)

        # Le chiuse vivono in DONE.md: dal 08/09/2026 il TODO.md tiene solo il lavoro aperto e
        # le voci [v]/[x] traslocano nell'archivio. Contarle solo qui farebbe sparire tutto il
        # fatto il giorno della potatura, con un salto nella curva che non corrisponde a niente.
        # grep -c stampa comunque il numero ed esce 1 quando non trova nulla: un
        # '|| echo 0' qui concatenerebbe due valori e romperebbe l'espressione aritmetica
        DONE_ARCH=0
        DROP_ARCH=0
        if [ -f DONE.md ]; then
            DONE_ARCH=$(grep -Ec '^- \[v\]' DONE.md)
            DROP_ARCH=$(grep -Ec '^- \[x\]' DONE.md)
        fi
        DONE=$(( $(grep -Ec '^- \[v\]' TODO.md) + DONE_ARCH ))
        DROP=$(( $(grep -Ec '^- \[x\]' TODO.md) + DROP_ARCH ))

        # dal 16/09/2026 il carico e' SOLO [ ]. [=] (in attesa di qualcuno, palla di un altro) e
        # [?] (sospesa, non si sa se va fatta) restano lavoro conosciuto ma non sono lavoro suo:
        # vanno nella colonna "attesa" invece di gonfiare il residuo. Prima [?] veniva sommata
        # alle aperte, ed e' il disallineamento annotato in .claude/rules/file-di-progetto.md
        # il 15/09: "32 mie, 29 su altri" e' l'informazione utile, "61 aperti" non lo e'
        TOT=$((TODO + WAIT + DEEP + DONE + DROP))

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
            # "attesa" = [=] su altri + [?] sospese, mostrate come "3 + 2"; vuota se non ce n'e'
            ATTESA=""
            if [ $((WAIT + DEEP)) -gt 0 ]; then
                ATTESA="$WAIT + $DEEP"
            fi
            printf "%12s" "$ATTESA"
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

# avanzamenti-todo
un altro gestore di cose da fare

# installazione
Scaricare l'archivio del branch main e scompattarlo, copiare tutti i file nelle relative cartelle, e creare il file /etc/avanzamenti.conf. All'interno di
questo file andrà specificato il valore della variabile BASE:

```
BASE=/home
```

che diversamente verrebbe valorizzata a default come /var/www.

# convenzione dei marcatori

Un progetto e' una cartella sotto `BASE` che contiene un `TODO.md`. Ogni cosa da
fare e' **una riga che inizia a colonna 1** con il suo marcatore:

```
- [ ] cosa da fare
- [=] decisa, ferma solo perche' la palla e' di un altro
- [?] cosa da fare, ma prima serve un approfondimento
- [v] fatta
- [x] scartata, tenuta solo per memoria storica
```

Il residuo e' `[ ]` + `[=]`, cioe' le due che torneranno: una `[=]` e' lavoro
deciso, aspetta qualcuno e prima o poi va fatta. Una `[?]` invece e' aperta ma non
si sa nemmeno se va fatta, quindi sta in "attesa" insieme a `[=]` nella colonna
del cruscotto e non gonfia il residuo -- tenerla dentro faceva sembrare il
progetto piu' carico di quello che e'.

`[v]` e `[x]` sono chiuse. Dal TODO.md di un progetto possono traslocare in un
`DONE.md` accanto: i contatori le sommano da tutti e due i file, altrimenti il
giorno della potatura sparirebbe tutto il fatto e la curva farebbe un salto che
non corrisponde a niente.

Non esistono altri marcatori: se ne trovi uno diverso e' un errore da
normalizzare.

Due regole che sembrano pignole e non lo sono, perche' i conteggi sono ancorati a
inizio riga:

- il `- ` iniziale ci vuole sempre, anche nelle voci di un elenco annidato;
- un marcatore citato dentro una frase o un blocco di codice non deve stare a
  inizio riga, o verrebbe contato come una cosa da fare.

# descrizione degli script

## /etc/cron.daily/backups
Questo script fa un backup di ogni progetto tutte le notti.

## /etc/cron.daily/burndown
Questo script aggiorna la burndown chart generale di tutti i progetti.

## /etc/cron.daily/upgrades
Questo script aggiorna il framework per i progetti che hanno il file update.branch.conf installato.

## /usr/local/bin/normalizza-urgenze.py e /etc/cron.d/normalizza-urgenze
Ogni sera alle 21:30 toglie l'urgenza alle voci ferme: una `- [ ]` col primo flag a `!` che non
cita nessuna data negli ultimi 14 giorni diventa `(-..)`, con `( declassata GG/MM/AAAA: ferma da
N gg )` in coda alla riga. Restano fuori `[=]`, `[?]`, le voci con una data futura e quelle senza
date. Senza `--applica` e' un'anteprima ( `-v` elenca le voci, `-p` filtra i progetti ). Il
resoconto della sera va in `/var/log/normalizza-urgenze.log`. La regola e' di Fabio, dell'08/10/2026,
ed e' scritta per i Claude nel regolamento della skill glisweb ( `riferimenti/cinque-file.md` ).

## /root/avanzamenti.sh
Questo script rappresenta la situazione attuale di tutti i progetti.

## /usr/local/bin/va.txt.progressbar.sh
Questa libreria contiene le funzioni che generano le progress bar.

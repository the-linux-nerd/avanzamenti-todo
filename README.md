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
- [?] cosa da fare, ma prima serve un approfondimento
- [v] fatta
- [x] scartata, tenuta solo per memoria storica
```

`[ ]` e `[?]` sono aperte e finiscono nel conteggio del residuo; `[v]` e `[x]` sono
chiuse. Non esistono altri marcatori: se ne trovi uno diverso e' un errore da
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

## /root/avanzamenti.sh
Questo script rappresenta la situazione attuale di tutti i progetti.

## /usr/local/bin/va.txt.progressbar.sh
Questa libreria contiene le funzioni che generano le progress bar.

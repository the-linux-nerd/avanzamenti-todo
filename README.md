# avanzamenti-todo
un altro gestore di cose da fare

# installazione
Scaricare l'archivio del branch main e scompattarlo, copiare tutti i file nelle relative cartelle, e creare il file /etc/avanzamenti.conf. All'interno di
questo file andrà specificato il valore della variabile BASE:

```
BASE=/home
```

che diversamente verrebbe valorizzata a default come /var/www.

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

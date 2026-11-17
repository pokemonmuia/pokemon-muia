# Pokémon Muia: regole per l'assistente

Fan game Pokémon ambientato a Muggia, fatto con Pokémon Essentials v21.1 (RPG Maker XP + mkxp-z). Ci lavorano due persone, spesso con Claude Code, direttamente su `main`. Testi del gioco e README in dialetto muggesano.

## Versione: alzala a ogni push

La versione del gioco è in `version.txt` (solo il numero, es. `1.01`). Il gioco la legge all'avvio (plugin `Muia Aggiornamenti`) e la scrive in ogni salvataggio.

1. Prima di lavorare: `git pull`.
2. Prima di ogni push su `main`: `git pull` di nuovo, poi alza `version.txt` di 0.01 nel commit (1.01 → 1.02 … 1.09 → 1.10 … 1.99 → 2.00). Un solo aumento per push, anche se il push contiene più commit.
3. Sempre due cifre dopo il punto: Essentials confronta le versioni cifra per cifra, quindi `1.1` al posto di `1.10` rompe l'ordine.
4. Conflitto su `version.txt`: prendi il numero più alto tra i due e aggiungi 0.01.
5. Se qualcuno fa push senza alzarla (per esempio da GitHub Desktop dopo aver lavorato in RPG Maker), la alza il workflow `.github/workflows/pages.yml` con un commit automatico "Versione X (automatica)". Per questo bisogna sempre fare pull prima di lavorare.

## Salvataggi che restano validi

I giocatori tengono i salvataggi tra una versione e l'altra. Quindi:

- Non rinumerare né riusare ID esistenti di mappe, switch, variabili, oggetti, specie, mosse o allenatori. Le cose nuove vanno in fondo.
- Se una modifica rende sbagliato un salvataggio vecchio (mappa rifatta o tolta, variabile che cambia significato, oggetto rimosso), aggiungi una conversione in fondo a `Plugins/Muia Aggiornamenti/script.rb` con `game_version` uguale alla versione che stai per pubblicare. C'è un esempio commentato.
- Prima di convertire, il gioco copia il salvataggio in `Game.rxdata.v<versione vecchia>.bak`.

## Plugin

`Game.exe` e la versione web caricano i plugin solo da `Data/PluginScripts.rxdata`, non dai file in `Plugins/`. Essentials lo ricompila solo provando il gioco da RPG Maker. Dopo aver cambiato o aggiunto un plugin, lancia `ruby Strumenti/compila_plugin.rb` e committa anche `Data/PluginScripts.rxdata`.

## Mappe e file binari

I file `.rxdata` non si possono unire. Prima di toccare una mappa, chiedi chi ci sta lavorando; non modificare mappe che l'utente non ha nominato.

## README

Ogni modifica che si vede nel gioco va aggiunta in fondo a `# AGGIORNAMENTI` nel README, in dialetto, con la data (formato `ggmmaaaa`).

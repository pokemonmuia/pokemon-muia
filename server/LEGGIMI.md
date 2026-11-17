# Server del multiplayer (browser e telefono)

Nel browser el zogo no pol verzer socket, quindi el multiplayer online passa da qua:

```
zogo (browser) → file nei salvataggi → pagina (web/gioca/ponte.ts) → WebSocket → ponte.js → server Ruby (UDP)
```

- `muia_server.rb` fa partir **lo stesso server del plugin** (`Plugins/Voltseon's Multiplayer Solution`): se se cambia el plugin, el server cambia anca lui.
- `ponte.js` riceve i WebSocket e ghe passa i messaggi al server Ruby, senza lexerli. El fa anca partir el server Ruby.
- Tuti i zogadori xe in un grupo solo (el grupo 0, massimo 4 zogadori, come nel server del plugin).

## Metterlo su Render (gratis)

1. Su <https://render.com> crear un account (con GitHub) e scegliere **New → Blueprint**, poi el repo `pokemon_muia.v1`. Render lexe `render.yaml` e crea el servizio `pokemon-muia-server` (piano **Free**).
2. Quando el xe pronto, el indirizzo xe tipo `https://pokemon-muia-server.onrender.com`. Se el nome xe diverso, cambiar `SERVER_MULTIPLAYER` in `web/gioca/main.ts` (solo la parte `qualcosa.onrender.com`).
3. Verificar: verzendo l'indirizzo nel browser deve comparir "Server Pokémon Muia: ativo".

Limiti del piano gratuito (verificai a novembre 2026, i pol cambiar): dopo 15 minuti senza traffico (i messaggi WebSocket conta) el servizio se spegne e al primo accesso ghe vol circa un minuto a ripartir; la pagina de Gioca mostra "Svejo el server...". Ghe xe 750 ore al mese par account.

## Provarlo sul computer

```
cd server && npm install && PORT=8088 node ponte.js
```
poi verzer la pagina del zogo da `localhost` con `?server=localhost:8088` in fondo all'indirizzo.

## Sicurezza (da saver)

El server Ruby decodifica i messaggi con `Marshal.load`, che con dati de sconosciuti no xe sicuro. Par questo el ponte accetta solo pagine de `https://pokemonmuia.github.io` (variabile `ORIGINI_OK`) e el server gira in un container separà, senza dati importanti. Mai metterghe dentro password o chiavi.

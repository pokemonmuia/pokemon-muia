module VMS
  # Toggle to display or hide player messages. (Set to false to disable)
  SHOW_PLAYER_MESSAGES = true

  # ===========
  # Errors
  # ===========
  # Message displayed when the server is inactive.
  SERVER_INACTIVE_MESSAGE = _INTL("El server par che nol sia ativo...")
  # Message displayed when the player is not connected to the server.
  NOT_CONNECTED_MESSAGE = _INTL("No te son conetù al server.")
  # Message displayed when the server is using a different game.
  DIFFERENT_GAME_MESSAGE = _INTL("El server al qual te volì conetarte par che el usi un altro zogo...")
  # Message displayed when the server is using a different version.
  DIFFERENT_VERSION_MESSAGE = _INTL("El server al qual te volì conetarte par che el usi una version diversa...")
  # Message displayed for a connection issue.
  CONNECTION_ISSUE_MESSAGE = _INTL("Par che ghe sia un problema de conession...\\wtnp[20]")
  # Basic error message.
  BASIC_ERROR_MESSAGE = _INTL("Xe sucedù un eror.")

  # ===========
  # General
  # ===========
  # Message displayed when disconnected from the server. (Set to "" to disable)
  DISCONNECTED_MESSAGE = _INTL("Te son stà desconetù.")
  # Message displayed upon server disconnection.
  SERVER_DISCONNECT_MESSAGE = _INTL("El server el te ga desconetù...")
  # Message displayed when attempting to connect to a full cluster.
  CLUSTER_FULL_MESSAGE = _INTL("El grupo al qual te volì entrar par che sia pien...")
  # Message displayed when asking for confirmation to disconnect from the server.
  DISCONNECT_CONFIRMATION_MESSAGE = _INTL("Sicuro de voler desconetarte?")

  # ===========
  # Interaction
  # ===========
  # Message displayed when another player wants to interact. {1} is the name of the player initiating the interaction.
  INTERACT_MESSAGE = _INTL("{1} el vol interagir con ti!\\wtnp[20]")
  # Message displayed when waiting for the player to say something during interaction. {1} is the name of the player waiting.
  INTERACTION_WAITING_FOR_YOU_MESSAGE = _INTL("{1} el speta con pazienza che te disi calcossa...")
  # Message displayed during interaction, prompting for a choice.
  INTERACTION_CHOICE = _INTL("Cossa vustu far?")
  # Message displayed when waiting for the player to say something during interaction. {1} is the name of the player waiting.
  INTERACTION_WAIT_MESSAGE = _INTL("Speto che {1} el disi calcossa...")
  # Message displayed when waiting for the player to respond during interaction. {1} is the name of the player waiting.
  INTERACTION_WAIT_RESPONSE_MESSAGE = _INTL("Speto che {1} el risponda...")
  # Message displayed when waiting for the player to start talking during interaction. {1} is the name of the player waiting.
  INTERACTION_WAIT_SWITCH_MESSAGE = _INTL("Speto che {1} el scominsi a parlar...")
  # Message displayed when the other player wants to trade during interaction. {1} is the name of the other player.
  INTERACTION_TRADE_MESSAGE = _INTL("{1} el vol scambiar con ti. \\wt[10]Aceti?")
  # Message displayed when the other player wants to battle during interaction. {1} is the name of the other player, {2} is the battle type.
  INTERACTION_BATTLE_MESSAGE = _INTL("{1} el vol far una {2} con ti. \\wt[10]Aceti?", "{1}", "{2}")
  # Message displayed when selecting a battle type.
  SELECT_BATTLE_TYPE_MESSAGE = _INTL("Siegli che tipo de lota:")
  # Battle type names.
  BATTLE_TYPE_SINGLE = _INTL("Lota singola")
  BATTLE_TYPE_DOUBLE = _INTL("Lota dopia")
  # Message displayed when selecting a party size.
  SELECT_PARTY_SIZE_MESSAGE = _INTL("Siegli quanti Pokémon doprar:")
  # Party size options.
  PARTY_SIZE_3 = _INTL("3 Pokémon")
  PARTY_SIZE_4 = _INTL("4 Pokémon")
  PARTY_SIZE_6 = _INTL("6 Pokémon")
  # Message displayed when a player doesn't have enough Pokémon for the selected size.
  NOT_ENOUGH_POKEMON_MESSAGE = _INTL("Un dei zogadori no ga abastanza Pokémon par sta lota.")

  # ===========
  # Interaction (Errors)
  # ===========
  # Message displayed when the interaction is canceled. {1} is the name of the player canceling the interaction.
  INTERACTION_CANCEL_MESSAGE = _INTL("A {1} no ghe interessa più interagir con ti. Che peccà...")
  # Message shown when attempting to interact with someone already interacting with another player. {1} represents the name of the player you are trying to interact with.
  ALREADY_INTERACTING_MESSAGE = _INTL("{1} el xe za drio interagir con un altro.")
  # Message displayed when the other player is busy. {1} is the name of the other player.
  INTERACTION_BUSY_MESSAGE = _INTL("{1} el xe ocupà.")
  # Message displayed when a player is engaged in a battle. {1} is the name of the other player.
  IN_A_BATTLE_MESSAGE = _INTL("{1} el xe in lota.")
  # Message displayed when a player is engaged in a trade. {1} is the name of the other player.
  IN_A_TRADE_MESSAGE = _INTL("{1} el xe drio scambiar.")
  # Message displayed when a player disconnects during an interaction. {1} is the name of the player who disconnected.
  PLAYER_DISCONNECT_MESSAGE = _INTL("{1} el se ga desconetù...")
  # Message displayed when a player does not respond. {1} is the name of the player who did not respond.
  PLAYER_NO_RESPONSE_MESSAGE = _INTL("{1} no ga risposto.")
  # Message displayed when you or the other player are not able to battle.
  INTERACTION_NO_BATTLE_MESSAGE = _INTL("Ti o l'altro zogador no pol lotar.")

  # ===========
  # Trading
  # ===========
  # Message displayed when the player has no tradable Pokémon.
  NO_TRADABLE_MESSAGE = _INTL("No te ghe Pokémon da scambiar.")
  # Message displayed when the trade is canceled by the other player. {1} is the name of the player canceling the trade.
  TRADE_CANCEL_MESSAGE = _INTL("{1} el ga deciso de no scambiar. Che peccà...")
  # Message displayed when the other player has no tradable Pokémon. {1} is the name of the other player.
  OTHER_NO_TRADABLE_MESSAGE = _INTL("{1} no ga Pokémon da scambiar.")
  # Message displayed when waiting for the other player to confirm a trade. {1} is the name of the player waiting.
  TRADE_WAIT_CONFIRM_MESSAGE = _INTL("Speto che {1} el sielgi un Pokémon...")
  # Message displayed when confirming a trade. {1} is the name of the Pokémon you are offering, and {2} is the name of the Pokémon the other player is offering.
  TRADE_CONFIRMATION_MESSAGE = _INTL("Sicuro de voler scambiar {1} con {2}?")
  # Message displayed when waiting for the other player to accept a trade. {1} is the name of the player waiting.
  TRADE_WAIT_ACCEPT_MESSAGE = _INTL("Speto che {1} el acèti.")

  # ===========
  # Swap
  # ===========
  # Message displayed when initiating a swap during interaction. {1} is the name of the player being swapped to.
  SWAP_INITIATION_MESSAGE = _INTL("Te vol interagir con {1}!\\wtnp[20]")
  # Message displayed when the other player wants you to talk to them during interaction. {1} is the name of the other player.
  INTERACTION_SWAP_MESSAGE = _INTL("{1} el vol che te ghe parli.\\wtnp[20]")

  # ===========
  # Menu
  # ===========
  # Message displayed for menu choices.
  MENU_CHOICES_MESSAGE = _INTL("Cossa vustu far?")
  # Message displayed when entering a cluster ID in the menu.
  MENU_ENTER_CLUSTER_ID_MESSAGE = _INTL("Scrivi el codice del grupo:")
  # Message displayed for an invalid cluster ID in the menu.
  MENU_INVALID_CLUSTER_MESSAGE = _INTL("Codice del grupo no valido.")
  # Message displayed when a cluster is not found, and a new one is created instead.
  MENU_CLUSTER_NOT_FOUND_MESSAGE = _INTL("Grupo no trovà; ne fazo uno novo.")
  # Message displayed when no clusters are available.
  NO_CLUSTERS_AVAILABLE_MESSAGE = _INTL("No ghe xe gnissun grupo. Ne fazo uno novo?")
  # Message displayed when selecting a cluster to join.
  SELECT_CLUSTER_MESSAGE = _INTL("Siegli un grupo dove entrar:")

  # ===========
  # Multi Battle
  # ===========
  # Title shown above the lobby browser list.
  MB_MENU_TITLE = _INTL("Sale per lota a quatro")
  # Label for the "create new lobby" option.
  MB_CREATE_LOBBY_OPTION = _INTL("Crea una sala nova")
  # Shown when no lobbies exist; asks if the player wants to create one.
  MB_NO_LOBBIES_MESSAGE = _INTL("No ghe xe sale per la lota a quatro. Ne fazo una nova?")
  # Prompt asking the player to choose a team.
  MB_SELECT_TEAM_MESSAGE = _INTL("Siegli la tua scuadra:")
  # Team and slot label options.
  MB_TEAM_0_SLOT_0 = _INTL("Scuadra 0 (Posto A)")
  MB_TEAM_0_SLOT_1 = _INTL("Scuadra 0 (Posto B)")
  MB_TEAM_1_SLOT_0 = _INTL("Scuadra 1 (Posto A)")
  MB_TEAM_1_SLOT_1 = _INTL("Scuadra 1 (Posto B)")
  # Shown when the chosen lobby is already full.
  MB_LOBBY_FULL_MESSAGE = _INTL("Sta sala xe za piena.")
  # Shown when the lobby wait times out.
  MB_LOBBY_TIMEOUT_MESSAGE = _INTL("Xe finì el tempo de la sala.")
  # Shown while waiting for all players to ready up.
  MB_READY_WAIT_MESSAGE = _INTL("Speto che tuti sia pronti...")
  # Shown while waiting for all players to select their Pokémon.
  MB_SELECTION_WAIT_MESSAGE = _INTL("Speto che tuti sielga i Pokémon...")
  # Shown when auto-reassigned to a different slot. {1} is the new slot label.
  MB_SLOT_CONFLICT_MESSAGE = _INTL("Posto ocupà: te son stà spostà a {1}.")
  # Shown when a player disconnects mid-battle. {1} is their name.
  MB_DISCONNECT_BATTLE_MESSAGE = _INTL("{1} el se ga desconetù. La lota xe finida.")
  # Shown to indicate that you must already be connected to use Multi Battle.
  MB_NOT_CONNECTED_MESSAGE = _INTL("Te ghe de esser conetù a un server par la lota a quatro.")
  # Prompt asking the player to confirm they are ready.
  MB_READY_CONFIRM_MESSAGE = _INTL("Pronto a lotar?")
  # Shown when a player has no eligible Pokémon for the multibattle.
  MB_NO_ELIGIBLE_POKEMON = _INTL("No te ghe abastanza Pokémon in forma par partecipar.")
end

# chosen pokemon is returned with this format:
#[[boxID, boxPosition],pokemon]

def pbChoosePokemonPC(positionVariableNumber, pokemonVarNumber, ableProc = nil)
  chosen = nil
  pokemon = nil

  pbFadeOutIn {
    scene = PokemonStorageScene.new
    screen = PokemonStorageScreen.new(scene, $PokemonStorage)
    screen.setFilter(ableProc) if ableProc
    chosen = screen.choosePokemon
    pokemon = $PokemonStorage[chosen[0]][chosen[1]] if chosen
    scene.pbCloseBox
  }
  pbSet(positionVariableNumber, chosen)
  pbSet(pokemonVarNumber, pokemon)
end

def npcTrade(npcPokemon_species, nickname, trainerName, playerPokemonProc)
  chosen_pokemon = pbChoosePokemon(1, 2, playerPokemonProc)
  chosen_position = pbGet(1)
  return nil if chosen_position <= -1
  pbStartTrade(chosen_position, npcPokemon_species, nickname, trainerName, 0)
end


BASIC_SHIRTS = {
:GRASS => "basicgrass",
:FIRE => "basicfire",
:WATER => "basicwater",
:BUG => "basicbug",
:NORMAL => "basicnormal",
:ROCK => "basicrock",
:GROUND => "basicground",
:STEEL => "basicsteel",
:PSYCHIC => "basicpsychic",
:POISON => "basicpoison",
:ICE => "basicice",
:GHOST => "basicghost",
:FLYING => "basicflying",
:FIGHT => "basicfight",
:FAIRY => "basicfairy",
:ELECTRIC => "basicelectric",
:DRAGON => "basicdragon",
:DARK => "basicdark",
}
def basicTypeShirts(event_id, nb_owned_for_reward = 5)
  GameData::Type.each do |type|
    nb_owned = 0
    GameData::Species.each do |species|
      if $Trainer.pokedex.owned?(species.species) && species.hasType?(type)
        nb_owned += 1
      end
    end
    if nb_owned >= nb_owned_for_reward
      clothes_reward = BASIC_SHIRTS[type.id]
      unless hasClothes?(clothes_reward)
        pbCallBub(2,event_id)
        pbMessage(_INTL("Let's see your Pokédex..."))
        pbCallBub(2,event_id)
        pbMessage(_INTL("Oh! You've caught {1} \\C[1]{2}-type\\C[0] Pokémon! You must be a huge {2} fan!",nb_owned,type.name))
        pbCallBub(2,event_id)
        pbMessage(_INTL("I have just the shirt for you. Here you go!"))
        obtainClothes(clothes_reward)
        return true
      end
    end
  end
  return false
end
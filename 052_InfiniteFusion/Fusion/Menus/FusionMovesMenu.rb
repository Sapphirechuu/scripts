class FusionMovesOptionsScene < PokemonOption_Scene
  attr_accessor :move1
  attr_accessor :move2
  attr_accessor :move3
  attr_accessor :move4

  def initialize(poke1, poke2)
    @poke1 = poke1
    @poke2 = poke2

    # The fusion is passed as @poke1. Should probably be refactored at some point
    @fused_pokemon = @poke1
    @head_species = @fused_pokemon.species_data.head_pokemon
    @body_species = @fused_pokemon.species_data.body_pokemon

    @move1 = @poke1.moves[0]
    @move2 = @poke1.moves[1]
    @move3 = @poke1.moves[2]
    @move4 = @poke1.moves[3]

    @index1 = 0
    @index2 = 0
    @index3 = 0
    @index4 = 0

    @selBaseColor = Color.new(48, 96, 216)
    @selShadowColor = Color.new(32, 32, 32)
  end

  def initUIElements
    Kernel.pbClearText()
    @sprites["pokeicon_fused"] = PokemonIconSprite.new(@fused_pokemon.species, @viewport)
    @sprites["pokeicon_fused"].x = 12
    @sprites["pokeicon_fused"].y = 0

    @sprites["titleMsg"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Select the moves you want to keep"), 64, 0, Graphics.width, 64, @viewport)
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(_INTL(""), 0, 20, Graphics.width, 64, @viewport)
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].letterbyletter = false
    @sprites["textbox"].baseColor = Color.new(64, 64, 64)       # dark gray text
    @sprites["textbox"].shadowColor = Color.new(168, 168, 168)  # lighter shadow
    addBackgroundPlane(@sprites, "bg_moves", "Fusion/movesOverlay", @viewport)
    addBackgroundPlane(@sprites, "bg_stats", "Fusion/statsOverlay", @viewport)
    @sprites["bg_stats"].visible = false
    showPokemonIcons
    pbSetSystemFont(@sprites["textbox"].contents)
  end

  CURSOR_X_OFFSET = 8
  CURSOR_Y_OFFSET = 16

  def showPokemonIcons
    @sprites["pokeicon_1"] = PokemonIconSprite.new(@body_species.species, @viewport)
    @sprites["pokeicon_1"].x = 240
    @sprites["pokeicon_1"].y = 50

    @sprites["pokeicon_2"] = PokemonIconSprite.new(@head_species.species, @viewport)
    @sprites["pokeicon_2"].x = 364
    @sprites["pokeicon_2"].y = 50

    @sprites["pokecursor"] = IconSprite.new(0, 0, @viewport)
    @sprites["pokecursor"].setBitmap("Graphics/Pictures/Fusion/cursor")
    @sprites["pokecursor"].x = @sprites["pokeicon_1"].x + CURSOR_X_OFFSET
    @sprites["pokecursor"].y = @sprites["pokeicon_1"].y + CURSOR_Y_OFFSET
    @sprites["pokecursor"].visible = true
  end

  def pbStartScene(inloadscreen = false)
    super
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 9999
    pbSetSystemFont(@sprites["overlay"].bitmap)

    @sprites["option"].nameBaseColor = MessageConfig::BLUE_TEXT_MAIN_COLOR
    @sprites["option"].nameShadowColor = MessageConfig::BLUE_TEXT_SHADOW_COLOR
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Select moves"), 0, 82, Graphics.width, 64, @viewport)
    @sprites["title"].setSkin("Graphics/Windowskins/invisible")
    @sprites["option"].setSkin("Graphics/Windowskins/invisible")
    #@sprites["textbox"].setSkin("Graphics/Windowskins/invisible")
    # @sprites["textbox"].text = "Select moves"
    updatePokemonCursor(0)
    updateDescription(0)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def getOptionsWidth(rect)
    width = super(rect)
    return width + 24
  end

  def draw_move_info(pokemonMove)
    @sprites["bg_stats"].visible = false
    @sprites["bg_moves"].visible = true
    move = GameData::Move.get(pokemonMove.id)
    label_base_color = Color.new(248, 248, 248)
    label_shadow_color = Color.new(104, 104, 104)

    value_base_color = Color.new(248, 248, 248)
    value_shadow_color = Color.new(104, 104, 104)

    @sprites["title"].text = _INTL("{1}", move.real_name)

    damage = move.base_damage == 0 ? "-" : move.base_damage.to_s
    accuracy = move.accuracy == 0 ? "100" : move.accuracy.to_s
    pp = move.total_pp.to_s
    if !move
      damage = "-"
      accuracy = "-"
      pp = "-"
    end

    start_y = 126
    gap_height = 32

    textpos = [
      [_INTL("Type"), 20, start_y, 0, label_base_color, label_shadow_color],
      [_INTL("Category"), 20, start_y + (gap_height * 1), 0, label_base_color, label_shadow_color],
      [_INTL("Power"), 20, start_y + (gap_height * 2), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", damage), 140, start_y + (gap_height * 2), 0, value_base_color, value_shadow_color],
      [_INTL("Accuracy"), 20, start_y + (gap_height * 3), 0, label_base_color, label_shadow_color],
      [_INTL("{1}%", accuracy), 140, start_y + (gap_height * 3), 0, value_base_color, value_shadow_color],
      [_INTL("PP"), 20, start_y + (gap_height * 4), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", pp), 140, start_y + (gap_height * 4), 0, value_base_color, value_shadow_color]
    ]

    imagepos = []
    type_number = GameData::Type.get(move.type).id_number
    category = move.category
    imagepos.push(["Graphics/Pictures/types", 140, start_y + (gap_height * 0) + 8, 0, type_number * 28, 64, 28])
    imagepos.push(["Graphics/Pictures/category", 140, start_y + (gap_height * 1) + 8, 0, category * 28, 64, 28])
    if !move
      imagepos = []
    end
    @sprites["overlay"].bitmap.clear
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    pbDrawImagePositions(@sprites["overlay"].bitmap, imagepos)

  end

  def draw_pokemon_info

    @sprites["bg_stats"].visible = true
    @sprites["bg_moves"].visible = false
    label_base_color = Color.new(248, 248, 248)
    label_shadow_color = Color.new(104, 104, 104)

    value_base_color = Color.new(248, 248, 248)
    value_shadow_color = Color.new(104, 104, 104)

    @sprites["title"].text = ""

    start_y = 94
    gap_height = 32

    textpos = [
      [_INTL("HP"), 20, start_y, 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.totalhp), 150, start_y, 0, label_base_color, label_shadow_color],

      [_INTL("Attack"), 20, start_y + (gap_height * 1), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.attack), 150, start_y + (gap_height * 1), 0, label_base_color, label_shadow_color],

      [_INTL("Defense"), 20, start_y + (gap_height * 2), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.defense), 150, start_y + (gap_height * 2), 0, label_base_color, label_shadow_color],

      [_INTL("Sp. Attack"), 20, start_y + (gap_height * 3), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.spatk), 150, start_y + (gap_height * 3), 0, value_base_color, value_shadow_color],

      [_INTL("Sp. Defense"), 20, start_y + (gap_height * 4), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.spdef), 150, start_y + (gap_height * 4), 0, value_base_color, value_shadow_color],

      [_INTL("Speed"), 20, start_y + (gap_height * 5), 0, label_base_color, label_shadow_color],
      [_INTL("{1}", @fused_pokemon.speed), 150, start_y + (gap_height * 5), 0, value_base_color, value_shadow_color],

    ]
    @sprites["overlay"].bitmap.clear
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
  end

  def draw_pokemon_type
    type1_number = GameData::Type.get(@poke1.type1).id_number
    type2_number = GameData::Type.get(@poke1.type2).id_number
    type1rect = Rect.new(0, type1_number * 28, 64, 28)
    type2rect = Rect.new(0, type2_number * 28, 64, 28)
    if @poke1.type1 == @poke1.type2
      overlay.blt(130, 78, @typebitmap.bitmap, type1rect)
    else
      overlay.blt(96, 78, @typebitmap.bitmap, type1rect)
      overlay.blt(166, 78, @typebitmap.bitmap, type2rect)
    end
  end

  def updatePokemonCursor(index)
    index = 0 if !index
    if @sprites["pokecursor"]
      if index == 0
        highlighted_value = @sprites["option"] ? (@sprites["option"][0] || 0) : 0
        @sprites["pokecursor"].visible = true
        @sprites["pokecursor"].x = highlighted_value == 0 ? @sprites["pokeicon_1"].x : @sprites["pokeicon_2"].x
        @sprites["pokecursor"].y = highlighted_value == 0 ? @sprites["pokeicon_1"].y : @sprites["pokeicon_2"].y
        @sprites["pokecursor"].x += CURSOR_X_OFFSET
        @sprites["pokecursor"].y += CURSOR_Y_OFFSET
      else
        @sprites["pokecursor"].visible = false
      end
    end
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    if @sprites["option"].mustUpdateDescription
      updatePokemonCursor(@sprites["option"].index)
      updateDescription(@sprites["option"].index)
      @sprites["option"].descriptionUpdated
    end
  end

  def updateDescription(index)
    index = 0 if !index
    begin
      highlighted_value = @sprites["option"] ? @sprites["option"][index] : 0
      highlighted_value ||= 0

      if index == 0
        @sprites["overlay"].bitmap.clear
        desc = highlighted_value == 0 ?
                 _INTL("Select all moves from {1}", GameData::Species.get(@body_species).real_name) :
                 _INTL("Select all moves from {1}", GameData::Species.get(@head_species).real_name)
        @sprites["textbox"].text = desc
        draw_pokemon_info
        return
      end

      move = case index
             when 1 then highlighted_value == 0 ? @poke1.moves[0] : @poke2.moves[0]
             when 2 then highlighted_value == 0 ? @poke1.moves[1] : @poke2.moves[1]
             when 3 then highlighted_value == 0 ? @poke1.moves[2] : @poke2.moves[2]
             when 4 then highlighted_value == 0 ? @poke1.moves[3] : @poke2.moves[3]
             else nil
             end

      if move
        draw_move_info(move)
        @sprites["textbox"].text = _INTL(getMoveDescription(move))
      else
        @sprites["overlay"].bitmap.clear
        @sprites["textbox"].text = getDefaultDescription
      end
    rescue => e
      @sprites["textbox"].text = getDefaultDescription
    end
  end

  def getDefaultDescription
    return _INTL("No move selected")
  end

  def getMoveForIndex(index)
    # Offset by 1 to skip the all moves button
    move_index = index - 1
    return nil if move_index < 0
    highlighted_value = @sprites["option"] ? (@sprites["option"][index] || 0) : 0
    case move_index
    when 0 then highlighted_value == 0 ? @poke1.moves[0] : @poke2.moves[0]
    when 1 then highlighted_value == 0 ? @poke1.moves[1] : @poke2.moves[1]
    when 2 then highlighted_value == 0 ? @poke1.moves[2] : @poke2.moves[2]
    when 3 then highlighted_value == 0 ? @poke1.moves[3] : @poke2.moves[3]
    end
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def getMoveName(move)
    return " - " if !@sprites["option"] && !move
    move = @poke1.moves[@sprites["option"].index] if !move
    return GameData::Move.get(move.id).real_name
  end

  def getMoveDescription(move)
    return " - " if !@sprites["option"] && !move
    move = @poke1.moves[@sprites["option"].index] if !move
    return GameData::Move.get(move.id).real_description
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL(""), ["", ""],
                     proc { 0 },
                     proc { |value|
                       @move1 = value == 0 ? @poke1.moves[0] : @poke2.moves[0]
                     }, [_INTL("Select all moves from {1}", GameData::Species.get(@head_species).real_name), _INTL("Select all moves from {1}", GameData::Species.get(@body_species).real_name)]
      ),

      EnumOption.new(_INTL(""), [_INTL(getMoveName(@poke1.moves[0])), _INTL(getMoveName(@poke2.moves[0]))],
                     proc { 1 },
                     proc { |value|
                       @move1 = value == 0 ? @poke1.moves[0] : @poke2.moves[0]
                     }, [getMoveDescription(@poke1.moves[0]), getMoveDescription(@poke2.moves[0])]
      ),
      EnumOption.new(_INTL(""), [_INTL(getMoveName(@poke1.moves[1])), _INTL(getMoveName(@poke2.moves[1]))],
                     proc { 1 },
                     proc { |value|
                       @move2 = value == 0 ? @poke1.moves[1] : @poke2.moves[1]
                     }, [getMoveDescription(@poke1.moves[1]), getMoveDescription(@poke2.moves[1])]
      ),
      EnumOption.new(_INTL(""), [_INTL(getMoveName(@poke1.moves[2])), _INTL(getMoveName(@poke2.moves[2]))],
                     proc { 1 },
                     proc { |value|
                       @move3 = value == 0 ? @poke1.moves[2] : @poke2.moves[2]
                     }, [getMoveDescription(@poke1.moves[2]), getMoveDescription(@poke2.moves[2])]
      ),
      EnumOption.new(_INTL(""), [_INTL(getMoveName(@poke1.moves[3])), _INTL(getMoveName(@poke2.moves[3]))],
                     proc { 1 },
                     proc { |value|
                       @move4 = value == 0 ? @poke1.moves[3] : @poke2.moves[3]
                     }, [getMoveDescription(@poke1.moves[3]), getMoveDescription(@poke2.moves[3])]
      )
    ]
    return options
  end

  def pbOptions
    oldSystemSkin = $PokemonSystem.frame # Menu
    oldTextSkin = $PokemonSystem.textskin # Speech
    pbActivateWindow(@sprites, "option") {
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["option"].mustUpdateOptions
          # Set the values of each option
          for i in 0...@PokemonOptions.length
            @PokemonOptions[i].set(@sprites["option"][i])
          end
          if $PokemonSystem.textskin != oldTextSkin
            @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
            @sprites["textbox"].text = _INTL("Speech frame {1}.", 1 + $PokemonSystem.textskin)
            oldTextSkin = $PokemonSystem.textskin
          end
          if $PokemonSystem.frame != oldSystemSkin
            @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame())
            @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame())
            oldSystemSkin = $PokemonSystem.frame
          end
        end
        if Input.trigger?(Input::USE)
          break if isConfirmedOnKeyPress
        end
      end
    }
  end

  def set_all_moves_to_index(index)
    [1, 2, 3, 4].each { |i| @sprites["option"][i] = index }
    source = index == 0 ? @poke1 : @poke2
    @move1 = source.moves[0]
    @move2 = source.moves[1]
    @move3 = source.moves[2]
    @move4 = source.moves[3]
    @sprites["option"].refresh
    updatePokemonCursor(@sprites["option"].index)
    updateDescription(@sprites["option"].index)
  end

  def isConfirmedOnKeyPress
    if @sprites["option"].index == 0
      current_side = @sprites["option"][0]
      all_already_selected = [1, 2, 3, 4].all? { |i| @sprites["option"][i] == current_side }
      if all_already_selected
        return true
      else
        pbSEPlay("GUI naming confirm")
        set_all_moves_to_index(current_side)
        return false
      end
    else
      return true
    end
  end

  def initOptionsWindow
    optionsWindow = Window_PokemonOptionFusionMoves.new(@PokemonOptions, 0,
                                                        @sprites["title"].height, Graphics.width,
                                                        Graphics.height - @sprites["title"].height - @sprites["textbox"].height)
    optionsWindow.viewport = @viewport
    optionsWindow.visible = true
    return optionsWindow
  end

end

class Window_PokemonOptionFusionMoves < Window_PokemonOption
  def initialize(options, x, y, width, height)
    super
    @mustUpdateOptions = true
    @mustUpdateDescription = true
    @confirmed = false
  end

  def drawCursor(index, rect)
    if self.index == index
      pbCopyBitmap(self.contents, @selarrow.bitmap, rect.x + 175, rect.y)
    end
    return Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
  end

  def dont_draw_item(index)
    return index == @options.length
  end
end
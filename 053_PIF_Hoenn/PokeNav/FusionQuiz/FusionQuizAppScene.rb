class FusionQuizAppScene < PokeNavAppScene
  def bg_path
    return "Graphics/Pictures/Pokegear/FusionQuiz/bg"
  end

  def header_name
    return _INTL("Fusion Quiz")
  end

  def click(button_id)
    $game_system.bgm_memorize
    case button_id
    when "play"
      pbBGMPlay("game_corner")
      @selected = :play
      @exiting = true
    when "score"
      @selected = :score
      @exiting = true
    when "exit"
      pbPlayCloseMenuSE
      @selected = :exit
      @exiting = true
    end
  end

  def selected_action
    return @selected
  end

  def pbEndSceneKeepBg
    @exiting = true
    sprites_without_bg = @sprites.reject { |k, _| ["bg", "background", "header"].include?(k) }
    pbFadeOutAndHide(sprites_without_bg) { pbUpdate }
    pbDisposeSpriteHash(sprites_without_bg)
    @buttons.each(&:dispose)
    Kernel.pbClearText
  end

  def disposeBg
    @sprites["bg"]&.dispose
    @sprites["background"]&.dispose
    @sprites["header"]&.dispose
    @viewport&.dispose
  end

  def pbEndScene
    echoln "ENDING"
    $game_system.bgm_restore
    super
  end


  end
class FusionQuizAppScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(main_menu_scene, screen)
    @main_menu_scene = main_menu_scene
    @screen = screen

    loop do
      btn_play  = PokenavButton.new("play",  nil, "Play")
      btn_score = PokenavButton.new("score", nil, "High-Score")
      btn_close = PokenavButton.new("exit",  nil, "Exit")

      @scene.pbStartScene([btn_play, btn_score, btn_close])
      @scene.pbScene

      case @scene.selected_action
      when :play
        @scene.pbEndSceneKeepBg
        launch_quiz
        @scene.disposeBg
      when :score
        @scene.pbEndSceneKeepBg
        show_high_score
        @scene.disposeBg
      when :exit, nil
        @scene.pbEndScene
        break
      end
    end
  end

  private

  def launch_quiz
    difficulty = prompt_difficulty
    nb_rounds = prompt_nb_rounds
    quiz = FusionQuiz.new(difficulty)
    quiz.silhouette_color = Color.new(0, 0, 0, 200)
    quiz.windowed = false
    quiz.picture_offset_x = -36

    quiz.start_quiz(nb_rounds)
    unless quiz.player_abandonned
      pbMessage(_INTL("You finished with {1} points!", quiz.get_score))
    end
  end

  def prompt_difficulty
    choice = pbMessage(
      _INTL("Choose a difficulty:"),
      [_INTL("Regular (4 choices)"), _INTL("Advanced (All Pokémon)")]
    )
    return choice == 1 ? :ADVANCED : :REGULAR
  end

  def prompt_nb_rounds
    choice = pbMessage(
      _INTL("Choose the number of rounds:"),
      [_INTL("3 Rounds"),
       _INTL("5 Rounds"),
       _INTL("10 Rounds")
      ]
    )
    possible_rounds = [3,5,10]
    return possible_rounds[choice]
  end

  def show_high_score
    high = pbGet(VAR_STAT_FUSION_QUIZ_HIGHEST_SCORE)
    total = pbGet(VAR_STAT_FUSION_QUIZ_TOTAL_PTS)
    times = pbGet(VAR_STAT_FUSION_QUIZ_NB_TIMES)
    pbMessage(_INTL("High Score: {1} pts", high))
    pbMessage(_INTL("Total Points: {1}\\nGames Played: {2}", total, times))
  end
end
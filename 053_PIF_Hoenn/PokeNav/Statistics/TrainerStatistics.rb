class TrainerStatistics
  attr_accessor :pokecenter_heals

  def initialize
    @pokecenter_heals = 0
    @nb_trades = 0
    @nb_battles_won = 0
  end

  def incr_nb_trades
    @nb_trades = 1 unless @nb_trades
    @nb_trades += 1
  end

  def incr_nb_battles_won
    @nb_battles_won = 1 unless @nb_battles_won
    @nb_battles_won += 1
  end
end
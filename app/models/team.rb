class Team < ActiveRecord::Base
  belongs_to :league
  has_many :season_standings
  has_many :weekly_results

  def lifetime_standings
    total_wins = season_standings.sum(:wins)
    total_losses = season_standings.sum(:losses)
    total_ties = season_standings.sum(:ties)

    { 
      name: name,
      wins: total_wins,
      losses: total_losses,
      ties: total_ties,
      winning_percentage: calculate_percentage(total_wins, (total_wins + total_losses + total_ties))
    } 
  end

  def weighted_lifetime_standings
    lifetime_hash = { name: name, weighted_wins: 0, actual_wins: 0, win_diff: 0, losses: 0, ties: 0 }

    years = [2011, 2012, 2013, 2014]

    years.each do |year|
      weighted_year = weighted_season_standings year
      binding.pry

      lifetime_hash[:weighted_wins] += weighted_year[:weighted_wins]
      lifetime_hash[:actual_wins] += weighted_year[:actual_wins]
      lifetime_hash[:win_diff] += weighted_year[:win_diff]
      lifetime_hash[:losses] += weighted_year[:losses]
      lifetime_hash[:ties] += weighted_year[:ties]
    end

    lifetime_hash
  end

  def weighted_season_standings(year)
    hash = { name: name, weighted_wins: 0, losses: 0, ties: 0 }

    weeks = weekly_results.where year: year

    other_teams = league.teams.reject { |team| team == self }

    weeks.each do |week|
      wins = 0
      losses = 0
      ties = 0

      other_teams.each do |other_team|
        points_scored = week.points_scored
        other_team_score = other_team.weekly_results.find_by(year: year, scoring_period: week.scoring_period).points_scored

        case
        when points_scored > other_team_score
          wins += 1
        when points_scored < other_team_score
          losses += 1
        when points_scored == other_team_score
          ties += 1
        end
      end

      hash[:weighted_wins] += (wins.to_f / other_teams.count.to_f)
      hash[:losses] += (losses.to_f / other_teams.count.to_f)
      hash[:ties] += (ties.to_f / other_teams.count.to_f)      
    end

    hash[:weighted_wins] = hash[:weighted_wins].round(3)
    hash[:losses] = hash[:losses].round(3)
    hash[:ties] = hash[:ties].round(3)

    standings = season_standings.find_by year: year
    hash[:win_diff] = (hash[:weighted_wins] - standings.wins).round(3)
    hash[:actual_wins] = standings.wins
    hash
  end

  def calculate_percentage(numerator, denominator)
    (numerator.to_f / denominator.to_f).round(3) 
  end
end

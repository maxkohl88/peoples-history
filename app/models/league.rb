require 'nokogiri'
require 'open-uri'

class League < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
  has_many :teams

  def collect_yearly_standings(year)
    doc = Nokogiri::HTML open("http://games.espn.go.com/flb/standings?leagueId=#{espn_id}&seasonId=#{year}")
    rows = doc.css 'table.tableBody tr.tableBody'
      
    rows[0..11].each do |row|
      attributes = team_espn_attributes row

      team = Team.find_or_initialize_by espn_id: attributes[:espn_id], league: self
      team.name = attributes[:name]
      team.save!

      wins_and_losses = row.elements[1..3]

      SeasonStanding.create! team: team, 
                             year: year, 
                             wins: wins_and_losses[0].text,
                             losses: wins_and_losses[1].text,
                             ties: wins_and_losses[2].text
    end
  end

  def collect_yearly_weekly_results(year)
    scoring_periods = (1..22).to_a

    scoring_periods.each { |scoring_period| collect_weekly_results year, scoring_period }
  end

  def collect_weekly_results(year, scoring_period)
    doc = Nokogiri::HTML open("http://games.espn.go.com/flb/scoreboard?leagueId=#{espn_id}&seasonId=#{year}&matchupPeriodId=#{scoring_period}")

    matchup_tables = doc.css 'table.matchup'

    matchup_tables.each do |matchup|
      first_team_info = matchup.elements[0]
      second_team_info = matchup.elements[1]

      first_team_url = first_team_info.css('a')[0]['href']
      second_team_url = second_team_info.css('a')[0]['href']

      first_team_espn_id = extract_team_espn_id_from_url first_team_url
      second_team_espn_id = extract_team_espn_id_from_url second_team_url

      WeeklyResult.create! team: teams.find_by(espn_id: first_team_espn_id),
                           opponent_id: second_team_espn_id,
                           points_scored: first_team_info.css('td').last['title'],
                           year: year,
                           scoring_period: scoring_period

      WeeklyResult.create! team: teams.find_by(espn_id: second_team_espn_id),
                           opponent_id: first_team_espn_id,
                           points_scored: second_team_info.css('td').last['title'],
                           year: year,
                           scoring_period: scoring_period      
    end
  end

  def weighted_season_standings
    standings = []

    teams.each do |team|
      standings << team.weighted_season_standings(2014)
    end

    standings.sort { |a, b| b[:weighted_wins] <=> a[:weighted_wins] }
  end

  def extract_team_espn_id_from_url(url)
    url.split('&teamId=')[1].split('&')[0]
  end

  def team_espn_attributes(nokogiri_row)
    team_url = nokogiri_row.css('a').first.attributes["href"].value
    team_id = team_url.split('&teamId=')[1].split('&').first
    team_name = nokogiri_row.css('a').first.attributes["title"].value.split(' (').first

    { espn_id: team_id, name: team_name }    
  end

  def sorted_lifetime_standings
    standings = []

    teams.each do |team|
      standings << team.lifetime_standings
    end

    standings.sort { |a, b| b[:wins] <=> a[:wins] }
  end
end

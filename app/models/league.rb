require 'nokogiri'
require 'open-uri'

class League < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
  has_many :teams

  def yearly_league_standings(year)
    doc = Nokogiri::HTML open("http://games.espn.go.com/flb/standings?leagueId=#{espn_id}&seasonId=#{year}")
    rows = doc.css 'table.tableBody tr.tableBody'
    rows.each do |row|
      team_url = row.css('a').first.attributes["href"].value
      team_id = team_url.split('&teamId=')[1].split('&').first
      team_name = row.css('a').first.attributes["title"].value.split(' (').first

      team = Team.find_or_initialize_by espn_id: team_id, league: self
      team.names << team_name
      team.save!
    end
  end
end

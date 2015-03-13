Sport.delete_all

sports = %w(Football Baseball Basketball)

sports.each do |sport|
  Sport.create! name: sport
end

# baseball = Sport.find_by name: 'Baseball'

# peoples = League.create! name: "The People's League", espn_id: 140424, sport_id: baseball.id

                      

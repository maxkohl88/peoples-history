Sport.delete_all

sports = %w(football baseball basketball)

sports.each do |sport|
  Sport.create! name: sport
end
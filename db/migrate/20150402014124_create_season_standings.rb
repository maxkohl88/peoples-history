class CreateSeasonStandings < ActiveRecord::Migration
  def change
    create_table :season_standings do |t|
      t.integer :wins
      t.integer :losses
      t.integer :ties
      t.integer :year
      t.references :team, index: true

      t.timestamps
    end
  end
end

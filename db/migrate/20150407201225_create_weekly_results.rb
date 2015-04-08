class CreateWeeklyResults < ActiveRecord::Migration
  def change
    create_table :weekly_results do |t|
      t.integer :points_scored
      t.integer :scoring_period
      t.integer :year
      t.integer :opponent_id
      t.references :team, index: true

      t.timestamps
    end
  end
end

class AddScoringPeriodCounterToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :scoring_period_counter, :integer
  end
end

class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.text :names, array: true, default: []
      t.integer :espn_id
      t.references :league, index: true

      t.timestamps
    end
  end
end

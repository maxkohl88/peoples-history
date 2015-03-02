class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues do |t|
      t.string :name
      t.integer :espn_id
      t.references :sport, index: true

      t.timestamps
    end
  end
end

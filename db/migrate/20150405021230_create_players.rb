class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :espn_id, unique: true
      t.string :name
      t.text :postions, array: true, default: []
      t.references :team, index: true

      t.timestamps
    end
  end
end

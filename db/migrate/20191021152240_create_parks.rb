class CreateParks < ActiveRecord::Migration[5.2]
  def change
    create_table :parks do |t|
      t.string :plate
      t.boolean :left, null: false, :default => false
      t.boolean :paid, null: false, :default => false
      t.datetime :left_in

      t.timestamps
    end
  end
end

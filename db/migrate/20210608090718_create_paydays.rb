class CreatePaydays < ActiveRecord::Migration[6.1]
  def change
    create_table :paydays do |t|
      t.string :name
      t.date :date
      t.text :recurring
      t.integer :user_id

      t.timestamps
    end
  end
end

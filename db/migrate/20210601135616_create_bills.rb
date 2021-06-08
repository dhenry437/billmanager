class CreateBills < ActiveRecord::Migration[6.1]
  def change
    create_table :bills do |t|
      t.string :name
      t.float :amount
      t.date :date
      t.text :recurring
      t.integer :user_id

      t.timestamps
    end
  end
end

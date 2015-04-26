class CreateResponders < ActiveRecord::Migration
  def change
    create_table :responders do |t|
      t.string :type
      t.string :name
      t.integer :capacity
      t.string :emergency_code
      t.boolean :on_duty,      default: false

      t.timestamps null: false
    end
  end
end

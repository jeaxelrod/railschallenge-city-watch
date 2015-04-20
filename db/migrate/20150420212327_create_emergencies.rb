class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies do |t|
      t.string :code
      t.integer :fire_severity
      t.integer :police_severity
      t.integer :medical_severity
      t.boolean :full_response
      t.time :resolved_at

      t.timestamps null: false
    end
  end
end

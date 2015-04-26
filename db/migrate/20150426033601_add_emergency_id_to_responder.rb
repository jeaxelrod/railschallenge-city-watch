class AddEmergencyIdToResponder < ActiveRecord::Migration
  def change
    add_column :responders, :emergency_id, :integer
  end
end

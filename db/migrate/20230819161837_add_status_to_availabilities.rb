class AddStatusToAvailabilities < ActiveRecord::Migration[7.0]
  def change
    add_column :availabilities, :status, :integer, default: 0
  end
end

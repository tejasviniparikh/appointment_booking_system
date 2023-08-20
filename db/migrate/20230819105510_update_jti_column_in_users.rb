class UpdateJtiColumnInUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :jti, false
    add_index :users, :jti, unique: true
  end
end

class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointments do |t|
      t.references :availability, foreign_key: true, null: false
      t.references :doctor, foreign_key: { to_table: :users }, null: false
      t.references :patient, foreign_key: { to_table: :users }, null: false
      t.integer :status, default: 0

      t.timestamps
    end
  end
end

class CreateAvailabilities < ActiveRecord::Migration[7.0]
  def change
    create_table :availabilities do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.references :doctor, foreign_key: { to_table: :users }, null: false

      t.timestamps
    end
  end
end

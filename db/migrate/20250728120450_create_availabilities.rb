class CreateAvailabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :availabilities do |t|
      t.references :space, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
    
    # Indexes for performance
    add_index :availabilities, [:space_id, :day_of_week]
    add_index :availabilities, :is_active
    
    # Check constraints
    add_check_constraint :availabilities, 
      "day_of_week >= 0 AND day_of_week <= 6", 
      name: 'day_of_week_range_check'
    add_check_constraint :availabilities, 
      "end_time > start_time", 
      name: 'time_range_check'
  end
end

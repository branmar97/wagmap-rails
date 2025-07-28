class CreateBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings do |t|
      # Foreign key references
      t.references :space, null: false, foreign_key: true
      t.references :renter, null: false, foreign_key: { to_table: :users }
      t.references :cancelled_by, null: true, foreign_key: { to_table: :users }
      
      # Booking time details
      t.date :booking_date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.decimal :duration_hours, precision: 4, scale: 2, null: false
      
      # Status and workflow
      t.integer :status, null: false, default: 0
      t.text :renter_message
      t.text :host_response_message
      
      # Pricing
      t.decimal :total_price, precision: 10, scale: 2
      t.decimal :price_per_dog_per_hour, precision: 8, scale: 2, null: false
      
      # Cancellation tracking
      t.datetime :cancellation_deadline
      t.datetime :cancelled_at
      t.text :cancellation_reason
      t.boolean :refund_eligible, default: false

      t.timestamps
    end
    
    # Indexes for performance
    add_index :bookings, [:space_id, :booking_date]
    add_index :bookings, [:renter_id, :status]
    add_index :bookings, :status
    add_index :bookings, [:booking_date, :start_time, :end_time]
    add_index :bookings, :cancelled_at
    
    # Check constraints for data integrity
    add_check_constraint :bookings, 
      "end_time > start_time", 
      name: 'booking_time_range_check'
    
    add_check_constraint :bookings, 
      "duration_hours > 0", 
      name: 'duration_positive_check'
    
    add_check_constraint :bookings, 
      "total_price >= 0", 
      name: 'total_price_non_negative_check'
    
    add_check_constraint :bookings, 
      "price_per_dog_per_hour > 0", 
      name: 'price_per_dog_positive_check'
    
    # Status enum constraint (0=pending, 1=approved, 2=denied, 3=cancelled, 4=completed)
    add_check_constraint :bookings, 
      "status IN (0, 1, 2, 3, 4)", 
      name: 'status_enum_check'
  end
end

class CreateBookingPets < ActiveRecord::Migration[7.2]
  def change
    create_table :booking_pets do |t|
      # Foreign key references
      t.references :booking, null: false, foreign_key: true
      t.references :pet, null: false, foreign_key: true

      t.timestamps
    end
    
    # Composite index for performance and uniqueness
    add_index :booking_pets, [:booking_id, :pet_id], unique: true, name: 'index_booking_pets_on_booking_and_pet'
  end
end

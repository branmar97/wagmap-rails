class CreateSpaces < ActiveRecord::Migration[7.2]
  def change
    create_table :spaces do |t|
      # User association
      t.references :user, null: false, foreign_key: true
      
      # Address Information
      t.string :address1, null: false, limit: 255
      t.string :address2, limit: 255
      t.string :city, null: false, limit: 100
      t.string :state, null: false, limit: 2
      t.string :zipcode, null: false, limit: 10
      
      # Property Details
      t.string :fencing_status, null: false
      t.string :space_size, null: false, limit: 100
      t.integer :max_dogs_per_booking, null: false
      t.decimal :price_per_dog, precision: 8, scale: 2, null: false
      
      # Environment Information
      t.boolean :other_dogs_visible_audible
      t.boolean :other_pets_visible_audible
      t.boolean :other_people_visible_audible
      
      # Operational
      t.string :status, null: false, default: 'active'

      t.timestamps
    end
    
    # Indexes for performance
    add_index :spaces, :status
    add_index :spaces, [:city, :state]
    
    # Check constraints for enum values
    add_check_constraint :spaces, "fencing_status IN ('fully_fenced', 'partially_fenced', 'not_fenced')", name: 'fencing_status_check'
    add_check_constraint :spaces, "status IN ('active', 'inactive')", name: 'status_check'
    add_check_constraint :spaces, "max_dogs_per_booking >= 1 AND max_dogs_per_booking <= 50", name: 'max_dogs_range_check'
    add_check_constraint :spaces, "price_per_dog > 0", name: 'price_positive_check'
  end
end

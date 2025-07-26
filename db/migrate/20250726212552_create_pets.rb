class CreatePets < ActiveRecord::Migration[7.2]
  def change
    create_table :pets do |t|
      t.string :name
      t.references :primary_breed, null: false, foreign_key: { to_table: :breeds }
      t.references :secondary_breed, null: false, foreign_key: { to_table: :breeds }
      t.references :user, null: false, foreign_key: true
      t.date :birthdate
      t.string :sex
      t.text :description
      t.boolean :health
      t.string :colors, array: true, default: []
      t.string :compatibilities, array: true, default: []

      t.timestamps
    end
  end
end

class Pet < ApplicationRecord
  belongs_to :primary_breed, class_name: 'Breed'
  belongs_to :secondary_breed, class_name: 'Breed'
  belongs_to :user

  validates :user_id, presence: true
  validates :name, presence: true
  validates :primary_breed_id, presence: true
  validates :birthdate, presence: true
  validates :sex, presence: true, inclusion: { in: %w(Male Female) }
  validates :description, length: { maximum: 500 }
end
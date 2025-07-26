class Pet < ApplicationRecord
  belongs_to :primary_breed, class_name: 'Breed'
  belongs_to :secondary_breed, class_name: 'Breed'
  belongs_to :user
end
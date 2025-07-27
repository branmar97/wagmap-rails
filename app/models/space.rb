class Space < ApplicationRecord
  # Associations
  belongs_to :user

  # Enums
  enum :fencing_status, {
    fully_fenced: 'fully_fenced',
    partially_fenced: 'partially_fenced',
    not_fenced: 'not_fenced'
  }

  enum :status, {
    active: 'active',
    inactive: 'inactive'
  }

  # Validations
  validates :address1, presence: true, length: { maximum: 255 }
  validates :address2, length: { maximum: 255 }
  validates :city, presence: true, length: { maximum: 100 }
  validates :state, presence: true, length: { is: 2 }, format: { 
    with: /\A[A-Z]{2}\z/, 
    message: "must be a valid 2-letter US state code" 
  }
  validates :zipcode, presence: true, length: { maximum: 10 }, format: { 
    with: /\A\d{5}(-\d{4})?\z/, 
    message: "must be a valid US zipcode (5 or 9 digits)" 
  }
  validates :fencing_status, presence: true
  validates :space_size, presence: true, length: { maximum: 100 }
  validates :max_dogs_per_booking, presence: true, numericality: { 
    only_integer: true, 
    in: 1..50 
  }
  validates :price_per_dog, presence: true, numericality: { 
    greater_than: 0 
  }
  validates :status, presence: true
end

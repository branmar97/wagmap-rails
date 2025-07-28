class Space < ApplicationRecord
  belongs_to :user
  has_many :availabilities, dependent: :destroy
  has_many :bookings, dependent: :destroy

  enum :fencing_status, {
    fully_fenced: 'fully_fenced',
    partially_fenced: 'partially_fenced',
    not_fenced: 'not_fenced'
  }

  enum :status, {
    active: 'active',
    inactive: 'inactive'
  }

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
  
  scope :bookable, -> { active.joins(:availabilities).where(availabilities: { is_active: true }).distinct }
  scope :with_availability, -> { joins(:availabilities).where(availabilities: { is_active: true }).distinct }
  scope :in_city, ->(city) { where(city: city) }
  scope :in_state, ->(state) { where(state: state) }
  scope :max_price, ->(price) { where('price_per_dog <= ?', price) }
  scope :min_capacity, ->(capacity) { where('max_dogs_per_booking >= ?', capacity) }
  
  def has_availability_on?(day_of_week)
    availabilities.active.for_day(day_of_week).exists?
  end
  
  def available_on_date?(date, start_time, end_time)
    day_of_week = date.wday
    
    # Check if space has availability pattern for this day and time
    availability = availabilities.active.for_day(day_of_week)
                                .where("start_time <= ? AND end_time >= ?", start_time, end_time)
                                .first
    
    return false unless availability
    
    # Space has availability pattern, so it's available
    true
  end
  
  def bookings_for_date(date)
    bookings.for_date(date).active
  end
  
  def approved_bookings_for_date(date)
    bookings.for_date(date).approved
  end
  
  def pending_bookings_for_date(date)
    bookings.for_date(date).pending
  end
  
  def calculate_booking_price(duration_hours, pet_count)
    return 0 unless price_per_dog && duration_hours && pet_count
    price_per_dog * duration_hours * pet_count
  end
  
  def hourly_rate
    price_per_dog
  end
  
  def can_accommodate_pets?(pet_count)
    pet_count <= max_dogs_per_booking
  end
  
  def is_bookable?
    active? && availabilities.active.exists?
  end
  
  def full_address
    parts = [address1, address2, city, state, zipcode].compact.reject(&:blank?)
    parts.join(', ')
  end
  
  def availability_summary
    return "No availability set" unless availabilities.active.exists?
    
    days_with_availability = availabilities.active.distinct.pluck(:day_of_week).sort
    day_names = days_with_availability.map { |day| Date::DAYNAMES[day] }
    
    case day_names.length
    when 1
      "Available on #{day_names.first}"
    when 2
      "Available on #{day_names.join(' and ')}"
    else
      "Available on #{day_names[0..-2].join(', ')} and #{day_names.last}"
    end
  end
end

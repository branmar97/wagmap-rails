class Booking < ApplicationRecord
  belongs_to :space
  belongs_to :user # The renter
  belongs_to :cancelled_by, class_name: 'User', optional: true
  has_many :booking_pets, dependent: :destroy
  has_many :pets, through: :booking_pets
  
  enum status: {
    pending: 0,
    approved: 1,
    denied: 2,
    cancelled: 3,
    completed: 4
  }
  
  validates :booking_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :duration_hours, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  validate :end_time_after_start_time
  validate :minimum_duration
  validate :booking_date_not_in_past
  validate :user_cannot_book_own_space
  validate :booking_within_availability
  
  scope :for_date, ->(date) { where(booking_date: date) }
  scope :for_date_range, ->(start_date, end_date) { where(booking_date: start_date..end_date) }
  scope :for_space, ->(space) { where(space: space) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_time_range, ->(start_time, end_time) do
    where("start_time < ? AND end_time > ?", end_time, start_time)
  end
  scope :active, -> { where.not(status: [:cancelled, :denied]) }
  scope :upcoming, -> { where('booking_date > ? OR (booking_date = ? AND start_time > ?)', Date.current, Date.current, Time.current) }
  scope :past, -> { where('booking_date < ? OR (booking_date = ? AND end_time < ?)', Date.current, Date.current, Time.current) }
  
  def start_datetime
    return nil unless booking_date && start_time
    booking_date.beginning_of_day + start_time.seconds_since_midnight.seconds
  end
  
  def end_datetime
    return nil unless booking_date && end_time
    booking_date.beginning_of_day + end_time.seconds_since_midnight.seconds
  end
  
  def duration_in_hours
    return 0 unless start_time && end_time
    ((end_time - start_time) / 1.hour).round(2)
  end
  
  def calculate_total_price
    return 0 unless space&.price_per_dog && duration_hours && pets.any?
    space.price_per_dog * duration_hours * pets.count
  end
  
  def can_be_cancelled?
    approved? && start_datetime && start_datetime > Time.current
  end
  
  def can_be_approved?
    pending? && start_datetime && start_datetime > Time.current
  end
  
  def can_be_denied?
    pending?
  end
  
  def overlaps_with?(other_booking)
    return false unless other_booking.is_a?(Booking)
    return false unless booking_date == other_booking.booking_date
    
    start_time < other_booking.end_time && end_time > other_booking.start_time
  end
  
  def cancellation_deadline
    return nil unless start_datetime
    start_datetime - 24.hours
  end
  
  def within_cancellation_deadline?
    return false unless cancellation_deadline
    Time.current < cancellation_deadline
  end
  
  def auto_complete_if_past!
    if approved? && end_datetime && end_datetime < Time.current
      update!(status: :completed)
    end
  end
  
  private
  
  def end_time_after_start_time
    return unless start_time && end_time
    
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
  
  def minimum_duration
    return unless start_time && end_time && end_time > start_time
    
    if duration_in_hours < 1.0
      errors.add(:base, "Booking duration must be at least 1 hour")
    end
  end
  
  def booking_date_not_in_past
    return unless booking_date
    
    if booking_date < Date.current
      errors.add(:booking_date, "cannot be in the past")
    elsif booking_date == Date.current && start_time && start_time <= Time.current.strftime('%H:%M:%S')
      errors.add(:start_time, "cannot be in the past")
    end
  end
  
  def user_cannot_book_own_space
    return unless user && space
    
    if user == space.user
      errors.add(:base, "You cannot book your own space")
    end
  end
  
  def booking_within_availability
    return unless space && booking_date && start_time && end_time
    
    # Check if the space has availability for this day and time
    day_of_week = booking_date.wday
    availability = space.availabilities.active.for_day(day_of_week)
                       .where("start_time <= ? AND end_time >= ?", start_time, end_time)
                       .first
    
    unless availability
      errors.add(:base, "Space is not available during the requested time")
    end
  end
end

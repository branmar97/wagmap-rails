class Availability < ApplicationRecord
  belongs_to :space

  # Validations
  validates :day_of_week, presence: true, inclusion: { in: 0..6, message: "must be between 0 (Sunday) and 6 (Saturday)" }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :is_active, inclusion: { in: [true, false] }
  
  # Custom validation for time range
  validate :end_time_after_start_time
  validate :reasonable_time_duration
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :for_day, ->(day) { where(day_of_week: day) }
  scope :for_space, ->(space) { where(space: space) }
  scope :overlapping, ->(start_time, end_time) do
    where("start_time < ? AND end_time > ?", end_time, start_time)
  end
  
  # Instance methods
  def day_name
    Date::DAYNAMES[day_of_week]
  end
  
  def formatted_time_range
    "#{start_time.strftime('%I:%M %p')} - #{end_time.strftime('%I:%M %p')}"
  end
  
  def duration_in_hours
    return 0 unless start_time && end_time
    ((end_time - start_time) / 1.hour).round(2)
  end
  
  def overlaps_with?(other_availability)
    return false unless other_availability.is_a?(Availability)
    return false unless day_of_week == other_availability.day_of_week
    
    start_time < other_availability.end_time && end_time > other_availability.start_time
  end
  
  private
  
  def end_time_after_start_time
    return unless start_time && end_time
    
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
  
  def reasonable_time_duration
    return unless start_time && end_time && end_time > start_time
    
    duration_hours = duration_in_hours
    
    if duration_hours < 1.0
      errors.add(:base, "Availability duration must be at least 1 hour")
    elsif duration_hours > 12
      errors.add(:base, "Availability duration cannot exceed 12 hours")
    end
  end
end

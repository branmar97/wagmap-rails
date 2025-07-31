class AvailabilityCalculator
  attr_reader :space

  def initialize(space)
    @space = space
  end

  # Get available time slots for a date range
  def get_available_slots(start_date, end_date)
    return [] unless space.is_bookable?
    
    slots = []
    current_date = start_date.to_date
    end_date = end_date.to_date
    
    while current_date <= end_date
      # Skip past dates
      next if current_date < Date.current
      
      day_slots = get_slots_for_date(current_date)
      slots.concat(day_slots) if day_slots.any?
      
      current_date += 1.day
    end
    
    slots
  end

  # Check if a specific time slot is available
  def check_slot_availability(start_datetime, duration_hours)
    return false unless space.is_bookable?
    return false if start_datetime < Time.current
    
    date = start_datetime.to_date
    start_time = start_datetime.strftime('%H:%M:%S')
    end_time = (start_datetime + duration_hours.hours).strftime('%H:%M:%S')
    
    # Check if space has availability pattern for this day and time
    space.available_on_date?(date, start_time, end_time)
  end

  # Get bookings that conflict with a proposed time slot
  def get_conflicting_bookings(start_datetime, end_datetime)
    return [] unless start_datetime && end_datetime
    
    date = start_datetime.to_date
    start_time = start_datetime.strftime('%H:%M:%S')
    end_time = end_datetime.strftime('%H:%M:%S')
    
    space.bookings.active
         .for_date(date)
         .for_time_range(start_time, end_time)
  end

  # Get all available time slots for a specific date
  def get_slots_for_date(date)
    return [] if date < Date.current
    
    day_of_week = date.wday
    availability_patterns = space.availabilities.active.for_day(day_of_week)
    
    slots = []
    
    availability_patterns.each do |pattern|
      slots.concat(generate_hourly_slots(date, pattern))
    end
    
    slots.sort_by { |slot| slot[:start_datetime] }
  end

  private

  # Generate hourly time slots from an availability pattern
  def generate_hourly_slots(date, pattern)
    slots = []
    
    current_time = combine_date_time(date, pattern.start_time)
    end_time = combine_date_time(date, pattern.end_time)
    
    # Generate slots in 1-hour increments
    while current_time < end_time
      slot_end = current_time + 1.hour
      
      # Don't create slots that extend beyond the availability window
      break if slot_end > end_time
      
      # Skip past time slots
      next if current_time < Time.current
      
      slots << {
        start_datetime: current_time,
        end_datetime: slot_end,
        start_time: current_time.strftime('%H:%M'),
        end_time: slot_end.strftime('%H:%M'),
        date: date.to_s,
        day_name: Date::DAYNAMES[date.wday],
        duration_hours: 1,
        price_per_dog: space.price_per_dog,
        available: true,
        space_id: space.id
      }
      
      current_time += 1.hour
    end
    
    slots
  end

  # Generate custom duration slots from an availability pattern
  def generate_custom_slots(date, pattern, duration_hours)
    slots = []
    
    current_time = combine_date_time(date, pattern.start_time)
    end_time = combine_date_time(date, pattern.end_time)
    duration = duration_hours.hours
    
    while current_time + duration <= end_time
      slot_end = current_time + duration
      
      # Skip past time slots
      if current_time >= Time.current
        slots << {
          start_datetime: current_time,
          end_datetime: slot_end,
          start_time: current_time.strftime('%H:%M'),
          end_time: slot_end.strftime('%H:%M'),
          date: date.to_s,
          day_name: Date::DAYNAMES[date.wday],
          duration_hours: duration_hours,
          price_per_dog: space.price_per_dog,
          total_price: space.calculate_booking_price(duration_hours, 1),
          available: true,
          space_id: space.id
        }
      end
      
      current_time += 1.hour # Move by 1 hour increments for slot starts
    end
    
    slots
  end

  # Get available slots for a specific duration
  def get_available_slots_for_duration(start_date, end_date, duration_hours)
    return [] unless space.is_bookable?
    return [] unless duration_hours >= 1
    
    slots = []
    current_date = start_date.to_date
    end_date = end_date.to_date
    
    while current_date <= end_date
      next if current_date < Date.current
      
      day_of_week = current_date.wday
      availability_patterns = space.availabilities.active.for_day(day_of_week)
      
      availability_patterns.each do |pattern|
        day_slots = generate_custom_slots(current_date, pattern, duration_hours)
        slots.concat(day_slots)
      end
      
      current_date += 1.day
    end
    
    slots.sort_by { |slot| slot[:start_datetime] }
  end

  # Calculate pricing for multiple pets
  def calculate_slot_price(duration_hours, pet_count = 1)
    space.calculate_booking_price(duration_hours, pet_count)
  end

  # Check if space can accommodate the number of pets
  def can_accommodate_pets?(pet_count)
    space.can_accommodate_pets?(pet_count)
  end

  # Get summary information about space availability
  def availability_summary
    return { available: false, message: "Space is not active" } unless space.active?
    return { available: false, message: "No availability pattern set" } unless space.availabilities.active.exists?
    
    patterns = space.availabilities.active.includes(:space)
    total_hours_per_week = patterns.sum(&:duration_in_hours)
    days_available = patterns.distinct.count(:day_of_week)
    
    {
      available: true,
      days_per_week: days_available,
      total_hours_per_week: total_hours_per_week,
      hourly_rate: space.price_per_dog,
      max_pets: space.max_dogs_per_booking,
      availability_description: space.availability_summary
    }
  end

  def self.slots_for_space(space, start_date, end_date)
    new(space).get_available_slots(start_date, end_date)
  end

  def self.check_availability(space, start_datetime, duration_hours)
    new(space).check_slot_availability(start_datetime, duration_hours)
  end

  def self.conflicting_bookings(space, start_datetime, end_datetime)
    new(space).get_conflicting_bookings(start_datetime, end_datetime)
  end

  private

  def combine_date_time(date, time)
    date.beginning_of_day + time.seconds_since_midnight.seconds
  end
end

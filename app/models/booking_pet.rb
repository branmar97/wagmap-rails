class BookingPet < ApplicationRecord
  belongs_to :booking
  belongs_to :pet
  
  validates :booking_id, presence: true
  validates :pet_id, presence: true
  validates :booking_id, uniqueness: { scope: :pet_id, message: "Pet is already included in this booking" }
  
  validate :pet_belongs_to_booking_renter
  validate :booking_is_not_completed_or_cancelled
  
  scope :for_booking, ->(booking) { where(booking: booking) }
  scope :for_pet, ->(pet) { where(pet: pet) }
  
  private
  
  def pet_belongs_to_booking_renter
    return unless booking && pet
    
    unless pet.user == booking.user
      errors.add(:pet, "must belong to the person making the booking")
    end
  end
  
  def booking_is_not_completed_or_cancelled
    return unless booking
    
    if booking.completed? || booking.cancelled?
      errors.add(:booking, "cannot add pets to completed or cancelled bookings")
    end
  end
end
